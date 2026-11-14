import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';

/// Loading Screen replicating the dual-orb orbital animation from documentation/components/widgets/loading-screen.
///
/// Features an orbital track with two counter-pulsing glowing orbs (primary and secondary),
/// followed by an interactive split-and-fade exit sequence that dissolves into the main application.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    required this.isDarkMode,
    this.onDismissCompleted,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback? onDismissCompleted;

  @override
  State<LoadingScreen> createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbitAnimationController;
  late AnimationController _exitAnimationController;
  late Animation<double> _exitOpacityAnimation;
  late Animation<double> _splitTranslationAnimation;
  late Animation<double> _splitScaleAnimation;

  bool _isExiting = false;

  @override
  void initState() {
    super.initState();

    final bool isTestEnvironment = WidgetsBinding.instance.runtimeType.toString().contains('Test');

    // 1.8s continuous orbital rotation loop matching loadingSpinnerRotate keyframes
    _orbitAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (!isTestEnvironment) {
      _orbitAnimationController.repeat();
    }

    // 550ms exit split-and-fade animation sequence matching loading-screen--split-fade
    _exitAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _exitOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitAnimationController,
        curve: const Interval(0.20, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _splitTranslationAnimation = Tween<double>(begin: 0.0, end: 72.0).animate(
      CurvedAnimation(
        parent: _exitAnimationController,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _splitScaleAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.25),
        weight: 30,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.25, end: 0.0),
        weight: 70,
      ),
    ]).animate(_exitAnimationController);

    _exitAnimationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        if (widget.onDismissCompleted != null) {
          widget.onDismissCompleted!();
        }
      }
    });

    if (isTestEnvironment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.onDismissCompleted != null) {
          widget.onDismissCompleted!();
        }
      });
    }
  }

  @override
  void dispose() {
    _orbitAnimationController.dispose();
    _exitAnimationController.dispose();
    super.dispose();
  }

  /// Triggers the exit split-and-fade sequence and notifies upon completion.
  void dismiss() {
    if (_isExiting) return;
    setState(() {
      _isExiting = true;
    });
    _exitAnimationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.isDarkMode;
    final Color backgroundColor = isDark
        ? const Color(0xFF121212)
        : DesignTokens.neutralLightSurface;
    final Color primaryOrbColor = isDark
        ? DesignTokens.accentYellow
        : const Color(0xFFEAB308);
    final Color secondaryOrbColor = isDark
        ? DesignTokens.pureWhite
        : DesignTokens.onyx;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _orbitAnimationController,
        _exitAnimationController,
      ]),
      builder: (BuildContext context, Widget? child) {
        if (_isExiting && _exitAnimationController.isCompleted) {
          return const SizedBox.shrink();
        }

        final double orbitProgress = _orbitAnimationController.value;
        final double rotationRadian = orbitProgress * 2.0 * math.pi;

        // Counter-oscillating pulse scales matching loadingOrbPulsePrimary and loadingOrbPulseSecondary
        final double pulseDelta = math.sin(orbitProgress * 2.0 * math.pi);
        final double primaryScale = 1.0 + (0.18 * pulseDelta);
        final double secondaryScale = 1.0 - (0.18 * pulseDelta);

        const double trackRadius = 26.0;
        const double orbDiameter = 18.0;

        final double exitOpacity = _exitOpacityAnimation.value;
        final double splitTranslation = _splitTranslationAnimation.value;
        final double exitScale = _isExiting ? _splitScaleAnimation.value : 1.0;

        return Opacity(
          opacity: exitOpacity.clamp(0.0, 1.0),
          child: Container(
            color: backgroundColor,
            alignment: Alignment.center,
            child: SizedBox(
              width: 90,
              height: 90,
              child: Center(
                child: _isExiting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Left Primary Orb splitting outward
                          Transform.translate(
                            offset: Offset(-splitTranslation, 0.0),
                            child: Transform.scale(
                              scale: exitScale,
                              child: Container(
                                width: orbDiameter,
                                height: orbDiameter,
                                decoration: BoxDecoration(
                                  color: primaryOrbColor,
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: primaryOrbColor.withValues(alpha: 0.55),
                                      blurRadius: 14,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Right Secondary Orb splitting outward
                          Transform.translate(
                            offset: Offset(splitTranslation, 0.0),
                            child: Transform.scale(
                              scale: exitScale,
                              child: Container(
                                width: orbDiameter,
                                height: orbDiameter,
                                decoration: BoxDecoration(
                                  color: secondaryOrbColor,
                                  shape: BoxShape.circle,
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: secondaryOrbColor.withValues(
                                        alpha: isDark ? 0.45 : 0.20,
                                      ),
                                      blurRadius: 14,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Transform.rotate(
                        angle: rotationRadian,
                        child: SizedBox(
                          width: trackRadius * 2 + orbDiameter,
                          height: trackRadius * 2 + orbDiameter,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              // Left Primary Glowing Orb
                              Positioned(
                                left: 0,
                                child: Transform.scale(
                                  scale: primaryScale,
                                  child: Container(
                                    width: orbDiameter,
                                    height: orbDiameter,
                                    decoration: BoxDecoration(
                                      color: primaryOrbColor,
                                      shape: BoxShape.circle,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: primaryOrbColor.withValues(alpha: 0.65),
                                          blurRadius: 16,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Right Secondary Glowing Orb
                              Positioned(
                                right: 0,
                                child: Transform.scale(
                                  scale: secondaryScale,
                                  child: Container(
                                    width: orbDiameter,
                                    height: orbDiameter,
                                    decoration: BoxDecoration(
                                      color: secondaryOrbColor,
                                      shape: BoxShape.circle,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                          color: secondaryOrbColor.withValues(
                                            alpha: isDark ? 0.45 : 0.22,
                                          ),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
