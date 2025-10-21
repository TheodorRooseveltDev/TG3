import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/underwater_theme.dart';

class FrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const FrostedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/logo/app_bbc_background_1.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: UnderwaterTheme.frostGlassTop(opacity: 0.1),
            child: AppBar(
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  shadows: UnderwaterTheme.textShadowLight,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: actions,
              bottom: bottom,
            ),
          ),
        ),
      ),
    );
  }
}
