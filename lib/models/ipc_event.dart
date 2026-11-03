enum IpcEventType {
  stepPrompt,
  stitching,
  completed,
  error,
  unknown,
}

class IpcEvent {
  const IpcEvent({
    required this.type,
    required this.message,
    this.step,
    this.outputPath,
    this.rawPayload = const <String, dynamic>{},
  });

  factory IpcEvent.fromJson(Map<String, dynamic> json) {
    final String rawEvent = (json['event'] as String? ?? '').toLowerCase();
    final IpcEventType type;
    switch (rawEvent) {
      case 'step_prompt':
      case 'stepprompt':
        type = IpcEventType.stepPrompt;
      case 'stitching':
        type = IpcEventType.stitching;
      case 'completed':
        type = IpcEventType.completed;
      case 'error':
        type = IpcEventType.error;
      default:
        type = IpcEventType.unknown;
    }

    return IpcEvent(
      type: type,
      message: (json['message'] as String?) ?? '',
      step: json['step'] as int?,
      outputPath: json['output_path'] as String? ?? json['outputPath'] as String?,
      rawPayload: json,
    );
  }

  final IpcEventType type;
  final String message;
  final int? step;
  final String? outputPath;
  final Map<String, dynamic> rawPayload;

  @override
  String toString() {
    return 'IpcEvent(type: $type, step: $step, message: "$message", outputPath: $outputPath)';
  }
}
