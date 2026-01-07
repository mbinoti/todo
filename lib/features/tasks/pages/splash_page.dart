import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const Color _accentGreen = Color(0xFF21B66E);
  static const Color _titleColor = Color(0xFF1D1E20);
  static const Color _mutedColor = Color(0xFF8C9097);

  @override
  Widget build(BuildContext context) {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final content = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7F9F8), Color(0xFFF2F5F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Logo(isIOS: isIOS),
              const SizedBox(height: 22),
              const Text(
                'TaskFlow',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _titleColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Organize sua vida',
                style: TextStyle(fontSize: 16, color: _mutedColor),
              ),
              const SizedBox(height: 26),
              _buildProgressIndicator(isIOS),
            ],
          ),
        ),
      ),
    );

    if (isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        child: content,
      );
    }
    return Scaffold(body: content);
  }

  Widget _buildProgressIndicator(bool isIOS) {
    if (isIOS) {
      return const CupertinoActivityIndicator(radius: 12, color: _accentGreen);
    }
    return const SizedBox(
      width: 26,
      height: 26,
      child: CircularProgressIndicator(
        strokeWidth: 2.6,
        valueColor: AlwaysStoppedAnimation<Color>(_accentGreen),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.isIOS});

  final bool isIOS;

  static const Color _accentGreen = Color(0xFF21B66E);

  @override
  Widget build(BuildContext context) {
    final iconData = isIOS
        ? CupertinoIcons.check_mark
        : Icons.check_box_outlined;
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: _accentGreen,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(child: Icon(iconData, size: 44, color: Colors.white)),
    );
  }
}
