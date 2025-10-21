import 'package:flutter/material.dart';

class UnderwaterTheme {
  // ========== UNDERWATER GRADIENT COLORS ==========
  
  // Top section (0-25%): Bright cyan/turquoise - shallow water near surface
  static const Color surfaceCyan1 = Color(0xFF00E5CC);
  static const Color surfaceCyan2 = Color(0xFF5FFBF1);
  
  // Upper-middle (25-45%): Light aqua blue - soft and ethereal
  static const Color upperAqua1 = Color(0xFF6BE4E6);
  static const Color upperAqua2 = Color(0xFF89E8EC);
  
  // Middle section (45-65%): Light cyan to periwinkle to lavender
  static const Color midCyan = Color(0xFFA0E7EA);
  static const Color midPeriwinkle = Color(0xFFB8CEE8);
  static const Color midLavender = Color(0xFFC5B8E6);
  
  // Lower-middle (65-80%): Deep purple-pink - misty and dreamy
  static const Color deepPurplePink1 = Color(0xFF9B7BC8);
  static const Color deepPurplePink2 = Color(0xFFB089C4);
  
  // Bottom section (80-100%): Rich deep navy and purple - ocean depths
  static const Color deepNavy1 = Color(0xFF4A3B7C);
  static const Color deepNavy2 = Color(0xFF2A1F5C);
  
  // ========== TEXT COLORS ==========
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textCyan = Color(0xFFE0FFFF);
  static const Color textDarkNavy = Color(0xFF2A1F5C);
  static const Color textDarkPurple = Color(0xFF4A3B7C);
  
  // ========== UI COMPONENT COLORS ==========
  static const Color cardPurple = Color(0xFF4A3B7C);
  static const Color cardPurpleMid = Color(0xFF5A4B8C);
  static const Color cardPurpleLight = Color(0xFF6B5B9C);
  
  // ========== GRADIENTS ==========
  
  // Full page background gradient
  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.85, 1.0],
    colors: [
      surfaceCyan1,      // 0% - Bright cyan
      surfaceCyan2,      // 25% - Turquoise
      upperAqua1,        // 35% - Light aqua
      upperAqua2,        // 45% - Soft aqua
      midPeriwinkle,     // 55% - Periwinkle
      midLavender,       // 65% - Lavender
      deepPurplePink1,   // 75% - Purple-pink
      deepNavy1,         // 85% - Deep navy
      deepNavy2,         // 100% - Deepest purple
    ],
  );
  
  // Header gradient (top section)
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      surfaceCyan1,
      surfaceCyan2,
      upperAqua1,
    ],
  );
  
  // Card gradient (middle section)
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      midPeriwinkle,
      midLavender,
      deepPurplePink2,
    ],
  );
  
  // Button gradient (cyan to purple)
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      surfaceCyan1,
      upperAqua2,
      deepPurplePink1,
    ],
  );
  
  // Bottom navigation gradient
  static const LinearGradient navGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      deepNavy1,
      deepNavy2,
    ],
  );
  
  // ========== GLASSMORPHISM HELPERS ==========
  
  // For frosted glass cards on top section (cyan backgrounds)
  static BoxDecoration frostGlassTop({double opacity = 0.2, double borderOpacity = 0.3}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          surfaceCyan1.withOpacity(opacity),
          surfaceCyan2.withOpacity(opacity * 0.8),
        ],
      ),
      border: Border.all(
        color: surfaceCyan2.withOpacity(borderOpacity),
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(16),
    );
  }
  
  // For frosted glass cards on middle section (lavender/purple backgrounds)
  static BoxDecoration frostGlassMid({double opacity = 0.25, double borderOpacity = 0.4}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          midLavender.withOpacity(opacity),
          deepPurplePink2.withOpacity(opacity * 0.9),
        ],
      ),
      border: Border.all(
        color: midPeriwinkle.withOpacity(borderOpacity),
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(16),
    );
  }
  
  // For frosted glass cards on bottom section (deep navy backgrounds)
  static BoxDecoration frostGlassDeep({double opacity = 0.3, double borderOpacity = 0.5}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          deepNavy1.withOpacity(opacity),
          cardPurpleMid.withOpacity(opacity),
        ],
      ),
      border: Border.all(
        color: deepPurplePink1.withOpacity(borderOpacity),
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(16),
    );
  }
  
  // ========== GLOW EFFECTS ==========
  
  static List<BoxShadow> glowCyan({double opacity = 0.3, double blur = 20}) {
    return [
      BoxShadow(
        color: surfaceCyan1.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: surfaceCyan2.withOpacity(opacity * 0.5),
        blurRadius: blur * 1.5,
        spreadRadius: 4,
      ),
    ];
  }
  
  static List<BoxShadow> glowPurple({double opacity = 0.25, double blur = 16}) {
    return [
      BoxShadow(
        color: deepPurplePink1.withOpacity(opacity),
        blurRadius: blur,
        spreadRadius: 2,
      ),
    ];
  }
  
  // ========== TEXT SHADOWS ==========
  
  static const List<Shadow> textShadowLight = [
    Shadow(
      color: Color(0x40000000),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];
  
  static const List<Shadow> textShadowGlow = [
    Shadow(
      color: surfaceCyan1,
      offset: Offset(0, 0),
      blurRadius: 10,
    ),
    Shadow(
      color: Color(0x60000000),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];
}
