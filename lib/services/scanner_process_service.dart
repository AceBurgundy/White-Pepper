import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../models/ipc_event.dart';
import 'cli_command_builder.dart';
import 'ipc_stream_parser.dart';

class ScannerProcessService {
  ScannerProcessService({
    String? projectRoot,
    this.pythonExecutable = 'python',
  }) : projectRoot = projectRoot ?? _resolveProjectRoot();

  static String _resolveProjectRoot() {
    final String currentPath = Directory.current.path;
    if (File(p.join(currentPath, 'scripts', 'scan_cli.py')).existsSync()) {
      return currentPath;
    }
    Directory candidate = File(Platform.resolvedExecutable).parent;
    for (int depth = 0; depth < 7; depth++) {
      if (File(p.join(candidate.path, 'scripts', 'scan_cli.py')).existsSync()) {
        return candidate.path;
      }
      final Directory parent = candidate.parent;
      if (parent.path == candidate.path) {
        break;
      }
      candidate = parent;
    }
    return currentPath;
  }

  final String projectRoot;
  final String pythonExecutable;

  Process? _activeProcess;
  StreamController<String>? _outputStreamController;

  bool get isRunning => _activeProcess != null;

  /// Execute a CLI command plan asynchronously with live output streaming.
  Stream<String> execute(
    CliCommandPlan plan, {
    void Function(IpcEvent)? onIpcEvent,
  }) {
    if (isRunning) {
      throw StateError('A scanner backend subprocess is already running.');
    }

    _outputStreamController = StreamController<String>.broadcast();
    final String fullScriptPath = p.join(projectRoot, plan.scriptRelativePath);

    final List<String> commandArgs = [fullScriptPath, ...plan.arguments];
    if (kDebugMode) {
      debugPrint('[Subprocess Launch] $pythonExecutable ${commandArgs.join(' ')}');
    }

    Process.start(
      pythonExecutable,
      commandArgs,
      workingDirectory: projectRoot,
      runInShell: true,
    ).then((Process process) {
      _activeProcess = process;

      // Handle standard output
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (String line) {
          final IpcEvent? event = IpcStreamParser.tryParseJsonLine(line);
          if (event != null && onIpcEvent != null) {
            onIpcEvent(event);
          }
          _outputStreamController?.add(line);
        },
        onError: (dynamic error) {
          _outputStreamController?.addError(error);
        },
      );

      // Handle standard error
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (String line) {
          _outputStreamController?.add('[stderr] $line');
        },
        onError: (dynamic error) {
          _outputStreamController?.addError(error);
        },
      );

      // Handle process completion
      process.exitCode.then((int exitCode) {
        if (kDebugMode) {
          debugPrint('[Subprocess Exit] code: $exitCode');
        }
        _outputStreamController?.add('[exit] Process completed with code $exitCode');
        _activeProcess = null;
        _outputStreamController?.close();
      });
    }).catchError((dynamic error) {
      _outputStreamController?.addError(error);
      _activeProcess = null;
      _outputStreamController?.close();
    });

    return _outputStreamController!.stream;
  }

  /// Send a line to the subprocess standard input (e.g., confirming step).
  void sendStdinLine(String line) {
    if (_activeProcess != null) {
      if (kDebugMode) {
        debugPrint('[Subprocess stdin] sending: $line');
      }
      _activeProcess!.stdin.writeln(line);
      _activeProcess!.stdin.flush();
    }
  }

  /// Cancel or terminate the active process.
  void cancelActiveProcess() {
    if (_activeProcess != null) {
      if (kDebugMode) {
        debugPrint('[Subprocess Terminate] Sending SIGTERM/SIGKILL');
      }
      _activeProcess!.kill(ProcessSignal.sigkill);
      _activeProcess = null;
      _outputStreamController?.add('[aborted] Subprocess manually terminated.');
      _outputStreamController?.close();
    }
  }

  /// Run hardware diagnostics via scripts/diagnostics_cli.py --json.
  Future<Map<String, dynamic>> runDiagnostics({
    String ip = '192.168.1.150',
    int port = 8080,
    double timeout = 6.0,
  }) async {
    final String diagnosticsScript = p.join(projectRoot, 'scripts', 'diagnostics_cli.py');
    final List<String> args = [
      diagnosticsScript,
      '--ip',
      ip,
      '--port',
      '$port',
      '--timeout',
      '$timeout',
      '--json',
    ];

    try {
      final ProcessResult result = await Process.run(
        pythonExecutable,
        args,
        workingDirectory: projectRoot,
        runInShell: true,
      );

      if (result.exitCode == 0 && result.stdout is String) {
        final String output = (result.stdout as String).trim();
        final dynamic decoded = jsonDecode(output);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return <String, dynamic>{
        'success': false,
        'message': result.stderr.toString().isNotEmpty
            ? result.stderr.toString()
            : 'Diagnostics failed with code ${result.exitCode}',
      };
    } catch (e) {
      return <String, dynamic>{
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
