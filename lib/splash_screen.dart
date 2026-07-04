import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';
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
    _initApp();
  }

  Future<bool> _checkConnectionOnly() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiBaseUrl}/currencies/active'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data != null && data['symbol'] != null) {
          Config.activeCurrencySymbol = data['symbol'].toString();
        }
      }
      return true;
    } catch (e) {
      debugPrint('Connection check failed: $e');
      return false;
    }
  }

  Future<void> _initApp() async {
    final startTime = DateTime.now();
    final hasConnection = await _checkConnectionOnly();

    if (!hasConnection) {
      if (mounted) {
        _showNoInternetDialog();
      }
      return;
    }

    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remaining = 2000 - elapsed;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }

    if (mounted) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SelectionPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isRetrying = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Color(0xFFDC2626)),
                  const SizedBox(width: 10),
                  const Text(
                    'Internet baglanyşygy ýok',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: Text(
                isRetrying
                    ? 'Baglanyşyk barlanýar, garaşyň...'
                    : 'Programmanyň işlemegi üçin internet gerek. Baglanyşygyňyzy barlaň we täzeden synanyşyň.',
                style: const TextStyle(fontSize: 15),
              ),
              actions: [
                if (!isRetrying)
                  TextButton(
                    onPressed: () async {
                      setStateDialog(() {
                        isRetrying = true;
                      });
                      
                      final success = await _checkConnectionOnly();
                      
                      if (success) {
                        Navigator.of(context).pop();
                        _navigateToHome();
                      } else {
                        setStateDialog(() {
                          isRetrying = false;
                        });
                      }
                    },
                    child: const Text(
                      'Täzeden synanyş',
                      style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
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
    );
  }
}
