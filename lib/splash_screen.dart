import 'package:flutter/material.dart';
import 'dart:async';
import 'selection_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _taglineOpacityAnimation;
  late Animation<double> _loaderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _taglineOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5, curve: Curves.easeOut),
      ),
    );

    _loaderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    _controller.forward();

    // Fade out and navigate to home after 2 seconds
    Timer(const Duration(milliseconds: 2000), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const SelectionPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth <= 640;

    final double title1Size = isSmallScreen ? 40 : 64;
    final double title2Size = isSmallScreen ? 14 : 20;
    final double taglineSize = isSmallScreen ? 16 : 24;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brand Title
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF111827), Color(0xFF4B5563)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: Text(
                              'DOGANLAR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: title1Size,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.02 * title1Size,
                                color: Colors.black,
                                height: 1.1,
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -8),
                            child: Text(
                              'FOTO MERKEZI',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: title2Size,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFDC2626),
                                letterSpacing: 0.5 * title2Size,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tagline
                      Opacity(
                        opacity: _taglineOpacityAnimation.value,
                        child: Text(
                          'Ýokary hil, amatly baha',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: taglineSize,
                            color: const Color(0xFF4B5563),
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.1 * taglineSize,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Loader Line
                      Container(
                        width: 200, // Fixed width for stability
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(1),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 200 * _loaderAnimation.value,
                            height: 2,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
