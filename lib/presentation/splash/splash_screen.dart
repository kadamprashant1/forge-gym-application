import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/app/theme.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  double _loadingProgress = 0.0;
  String _loadingStatus = 'Initializing core...';
  final List<String> _statusMessages = [
    'Initializing core...',
    'Loading workout routines...',
    'Synchronizing progress...',
    'Calibrating iron...',
    'Ready',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );

    _controller.forward();
    _startBootSequence();
  }

  void _startBootSequence() {
    const totalDuration = Duration(milliseconds: 3000);
    const interval = Duration(milliseconds: 50);
    int elapsed = 0;

    Timer.periodic(interval, (timer) {
      elapsed += interval.inMilliseconds;
      setState(() {
        _loadingProgress = (elapsed / totalDuration.inMilliseconds).clamp(0.0, 1.0);
        int messageIndex = (_loadingProgress * (_statusMessages.length - 1)).floor();
        _loadingStatus = _statusMessages[messageIndex];
      });

      if (elapsed >= totalDuration.inMilliseconds) {
        timer.cancel();
        if (mounted) {
          context.go('/');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withOpacity(0.05),
                    AppTheme.primary,
                  ],
                  radius: 1.2,
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Branded PNG Logo
                        Container(
                          width: 150,
                          height: 150,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.1),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/icon/forge_icon.png',
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'FORGE',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                letterSpacing: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'YOUR EVOLUTION',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                letterSpacing: 4,
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w300,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 80,
            left: 40,
            right: 40,
            child: Column(
              children: [
                Text(
                  _loadingStatus.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _loadingProgress,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                    minHeight: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_loadingProgress * 100).toInt()}%',
                  style: TextStyle(
                    color: AppTheme.accent.withOpacity(0.5),
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
