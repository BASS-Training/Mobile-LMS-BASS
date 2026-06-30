import 'package:flutter/material.dart';

class AppColors {
  // ==========================================
  // NEUTRALS, GRAYS, WHITES & BLACKS
  // ==========================================
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color quizBackgroundStart = Color(0xFFF8FAFF);
  static const Color quizBackgroundEnd = Color(0xFFF1F4FF);
  // These four legacy neutrals are widely used as text/border/background, so
  // they are theme-aware (see _pick + brightness defined in the semantic
  // section below) to adapt for dark mode.
  static Color get mist => _pick(const Color(0xFFF8F9FA), const Color(0xFF1C1E21));
  static Color get pearl => _pick(const Color(0xFFE0E0E0), const Color(0xFF3A3E44));
  static Color get charcoal => _pick(const Color(0xFF2D3436), const Color(0xFFF1F2F4));
  static Color get slate => _pick(const Color(0xFF636E72), const Color(0xFFAEB4BD));
  static const Color silver = Color(0xFFB2BEC3);
  static const Color graphite = Color(0xFF1F2937);
  static const Color stone = Color(0xFF6B7280);
  static const Color cloud = Color(0xFFF3F4F6);

  // New Neutrals
  static const Color snow = Color(0xFFFFFAFA);
  static const Color floralWhite = Color(0xFFFFFAF0);
  static const Color ghostWhite = Color(0xFFF8F8FF);
  static const Color aliceBlue = Color(0xFFF0F8FF);
  static const Color honeydew = Color(0xFFF0FFF0);
  static const Color alabaster = Color(0xFFEDEADE);
  static const Color gainsboro = Color(0xFFDCDCDC);
  static const Color lightGray = Color(0xFFD3D3D3);
  static const Color gray = Color(0xFF808080);
  static const Color darkGray = Color(0xFFA9A9A9);
  static const Color dimGray = Color(0xFF696969);
  static const Color ash = Color(0xFFB2BEB5);
  static const Color pewter = Color(0xFF8E9E9D);
  static const Color iron = Color(0xFF48494B);
  static const Color steel = Color(0xFF4682B4);
  static const Color jet = Color(0xFF343434);
  static const Color ebony = Color(0xFF555D50);
  static const Color onyx = Color(0xFF353839);
  static const Color gunmetal = Color(0xFF2A3439);
  static const Color obsidian = Color(0xFF0B1215);
  static const Color raven = Color(0xFF050301);

  // ==========================================
  // BROWNS & EARTH TONES
  // ==========================================
  static const Color brown = Color(0xFF8B5E34);
  static const Color chocolate = Color(0xFF5C3A21);
  static const Color sand = Color(0xFFF5DEB3);
  static const Color beige = Color(0xFFF5F5DC);
  static const Color ivory = Color(0xFFFFFFF0);

  // New Browns
  static const Color cornsilk = Color(0xFFFFF8DC);
  static const Color bisque = Color(0xFFFFE4C4);
  static const Color moccasin = Color(0xFFFFE4B5);
  static const Color wheat = Color(0xFFF5DEB3);
  static const Color burlywood = Color(0xFFDEB887);
  static const Color tan = Color(0xFFD2B48C);
  static const Color rosyBrown = Color(0xFFBC8F8F);
  static const Color sandyBrown = Color(0xFFF4A460);
  static const Color goldenrod = Color(0xFFDAA520);
  static const Color darkGoldenrod = Color(0xFFB8860B);
  static const Color peru = Color(0xFFCD853F);
  static const Color saddleBrown = Color(0xFF8B4513);
  static const Color sienna = Color(0xFFA0522D);
  static const Color maroonColor = Color(0xFF800000);
  static const Color copper = Color(0xFFB87333);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color mahogany = Color(0xFFC04000);
  static const Color chestnut = Color(0xFF954535);
  static const Color walnut = Color(0xFF773F1A);
  static const Color coffee = Color(0xFF6F4E37);
  static const Color mochaColor = Color(0xFF4E312D);
  static const Color caramelColor = Color(0xFFC68E17);
  static const Color taupe = Color(0xFF483C32);
  static const Color umber = Color(0xFF635147);
  static const Color sepia = Color(0xFF704214);
  static const Color khaki = Color(0xFFF0E68C);

  // ==========================================
  // REDS & PINKS
  // ==========================================
  static const Color coral = Color(0xFFE76F51);
  static const Color rose = Color(0xFFEF4444);
  static const Color crimson = Color(0xFFC1121F);
  static const Color cherry = Color(0xFFB91C1C);
  static const Color scarlet = Color(0xFFE11D48);
  static const Color ruby = Color(0xFF8F1D21);
  static const Color burgundy = Color(0xFF7F1D1D);
  static const Color peach = Color(0xFFFDE7E1);
  static const Color salmon = Color(0xFFF97373);

  // New Reds & Pinks
  static const Color lightPink = Color(0xFFFFB6C1);
  static const Color pink = Color(0xFFFFC0CB);
  static const Color hotPink = Color(0xFFFF69B4);
  static const Color deepPink = Color(0xFFFF1493);
  static const Color paleVioletRed = Color(0xFFDB7093);
  static const Color lightSalmon = Color(0xFFFFA07A);
  static const Color darkSalmon = Color(0xFFE9967A);
  static const Color lightCoral = Color(0xFFF08080);
  static const Color indianRed = Color(0xFFCD5C5C);
  static const Color fireBrick = Color(0xFFB22222);
  static const Color darkRed = Color(0xFF8B0000);
  static const Color bloodRed = Color(0xFF660000);
  static const Color tomato = Color(0xFFFF6347);
  static const Color amaranth = Color(0xFFE52B50);
  static const Color carmine = Color(0xFF960018);
  static const Color cerise = Color(0xFFDE3163);
  static const Color fuchsia = Color(0xFFFF00FF);
  static const Color raspberry = Color(0xFFE30B5D);
  static const Color strawberry = Color(0xFFFC5A8D);
  static const Color watermelon = Color(0xFFFC6C85);
  static const Color blush = Color(0xFFDE5D83);
  static const Color bubblegum = Color(0xFFFFC1CC);
  static const Color flamingo = Color(0xFFFC8EAC);
  static const Color rouge = Color(0xFFA23B6C);
  static const Color wine = Color(0xFF722F37);
  static const Color claret = Color(0xFF7F1734);

  // ==========================================
  // ORANGES & YELLOWS
  // ==========================================
  static const Color apricot = Color(0xFFF6C28B);
  static const Color amber = Color(0xFFC9A227);
  static const Color tangerine = Color(0xFFF59E0B);
  static const Color pumpkin = Color(0xFFD97706);
  static const Color lemon = Color(0xFFF8D66D);
  static const Color gold = Color(0xFFD4A017);
  static const Color mustard = Color(0xFFB45309);

  // New Oranges & Yellows
  static const Color lightYellow = Color(0xFFFFFFE0);
  static const Color yellow = Color(0xFFFFFF00);
  static const Color papayaWhip = Color(0xFFFFEFD5);
  static const Color peachPuff = Color(0xFFFFDAB9);
  static const Color orange = Color(0xFFFFA500);
  static const Color darkOrange = Color(0xFFFF8C00);
  static const Color mango = Color(0xFFF4BB44);
  static const Color cantaloupe = Color(0xFFFDA172);
  static const Color carrot = Color(0xFFED9121);
  static const Color yam = Color(0xFFE17E4E);
  static const Color squash = Color(0xFFE69A26);
  static const Color saffron = Color(0xFFF4C430);
  static const Color sunflower = Color(0xFFFFDA03);
  static const Color butter = Color(0xFFFFFD74);
  static const Color banana = Color(0xFFFFE135);
  static const Color flax = Color(0xFFEEDC82);
  static const Color cream = Color(0xFFFFFDD0);
  static const Color vanilla = Color(0xFFF3E5AB);
  static const Color honey = Color(0xFFFFC30B);
  static const Color dijon = Color(0xFFC49102);
  static const Color citrus = Color(0xFFF2A900);
  static const Color marigold = Color(0xFFEAA221);
  static const Color butterscotch = Color(0xFFE3963E);

  // ==========================================
  // GREENS
  // ==========================================
  static const Color emerald = Color(0xFF27AE60);
  static const Color mint = Color(0xFF6EE7B7);
  static const Color jade = Color(0xFF10B981);
  static const Color forest = Color(0xFF166534);
  static const Color olive = Color(0xFF4D7C0F);
  static const Color turquoise = Color(0xFF14B8A6);

  // New Greens
  static const Color greenYellow = Color(0xFFADFF2F);
  static const Color chartreuse = Color(0xFF7FFF00);
  static const Color lawnGreen = Color(0xFF7CFC00);
  static const Color lime = Color(0xFF00FF00);
  static const Color limeGreen = Color(0xFF32CD32);
  static const Color paleGreen = Color(0xFF98FB98);
  static const Color lightGreen = Color(0xFF90EE90);
  static const Color mediumSpringGreen = Color(0xFF00FA9A);
  static const Color springGreen = Color(0xFF00FF7F);
  static const Color mediumSeaGreen = Color(0xFF3CB371);
  static const Color seaGreen = Color(0xFF2E8B57);
  static const Color darkGreen = Color(0xFF006400);
  static const Color yellowGreen = Color(0xFF9ACD32);
  static const Color darkOliveGreen = Color(0xFF556B2F);
  static const Color teal = Color(0xFF008080);
  static const Color aquamarine = Color(0xFF7FFFD4);
  static const Color pine = Color(0xFF01796F);
  static const Color fern = Color(0xFF4F7942);
  static const Color moss = Color(0xFF8A9A5B);
  static const Color sage = Color(0xFF9DC183);
  static const Color shamrock = Color(0xFF009E60);
  static const Color seafoam = Color(0xFF9FE2BF);
  static const Color pistachio = Color(0xFF93C572);
  static const Color basil = Color(0xFF589F6B);
  static const Color artichoke = Color(0xFF8F9779);
  static const Color celadon = Color(0xFFAFE1AF);
  static const Color viridian = Color(0xFF40826D);
  static const Color juniper = Color(0xFF6A9B8D);

  // ==========================================
  // BLUES & CYANS
  // ==========================================
  static const Color azure = Color(0xFFC9A227);
  static const Color sky = Color(0xFFF4D06F);
  static const Color cobalt = Color(0xFF8F1D21);
  static const Color ocean = Color(0xFFB91C1C);
  static const Color navy = Color(0xFF5C1A1B);
  static const Color midnight = Color(0xFF2B090A);
  static const Color denim = Color(0xFFAA1E2C);
  static const Color sapphire = Color(0xFFD72638);
  static const Color cyan = Color(0xFFFFD166);

  // New Blues
  static const Color powderBlue = Color(0xFFB0E0E6);
  static const Color lightBlue = Color(0xFFADD8E6);
  static const Color deepSkyBlue = Color(0xFF00BFFF);
  static const Color dodgerBlue = Color(0xFF1E90FF);
  static const Color cornflowerBlue = Color(0xFF6495ED);
  static const Color mediumSlateBlue = Color(0xFF7B68EE);
  static const Color royalBlue = Color(0xFF4169E1);
  static const Color blue = Color(0xFF0000FF);
  static const Color mediumBlue = Color(0xFF0000CD);
  static const Color darkBlue = Color(0xFF00008B);
  static const Color aqua = Color(0xFF00FFFF);
  static const Color cadetBlue = Color(0xFF5F9EA0);
  static const Color steelBlue = Color(0xFF4682B4);
  static const Color lightSteelBlue = Color(0xFFB0C4DE);
  static const Color slateBlue = Color(0xFF6A5ACD);
  static const Color darkSlateBlue = Color(0xFF483D8B);
  static const Color cerulean = Color(0xFF007BA7);
  static const Color lapis = Color(0xFF26619C);
  static const Color aegean = Color(0xFF1F456E);
  static const Color berry = Color(0xFF241571);
  static const Color indigoDye = Color(0xFF00416A);
  static const Color periwinkle = Color(0xFFCCCCFF);
  static const Color babyBlue = Color(0xFF89CFF0);
  static const Color tealBlue = Color(0xFF367588);
  static const Color peacock = Color(0xFF00A2E8);
  static const Color ice = Color(0xFF71A6D2);
  static const Color frost = Color(0xFFE1F5FE);

  // ==========================================
  // PURPLES, VIOLETS & MAGENTAS
  // ==========================================
  static const Color violet = Color(0xFF6C5CE7);
  static const Color lavender = Color(0xFFA29BFE);
  static const Color indigo = Color(0xFF5F3DC4);
  static const Color lilac = Color(0xFFC4B5FD);
  static const Color plum = Color(0xFF7E22CE);
  static const Color orchid = Color(0xFFA855F7);
  static const Color magenta = Color(0xFFD946EF);

  // New Purples
  static const Color thistle = Color(0xFFD8BFD8);
  static const Color mediumOrchid = Color(0xFFBA55D3);
  static const Color darkOrchid = Color(0xFF9932CC);
  static const Color darkViolet = Color(0xFF9400D3);
  static const Color darkMagenta = Color(0xFF8B008B);
  static const Color purple = Color(0xFF800080);
  static const Color mediumPurple = Color(0xFF9370DB);
  static const Color rebeccaPurple = Color(0xFF663399);
  static const Color blueViolet = Color(0xFF8A2BE2);
  static const Color amethyst = Color(0xFF9966CC);
  static const Color heliotrope = Color(0xFFDF73FF);
  static const Color mauve = Color(0xFFE0B0FF);
  static const Color mulberry = Color(0xFFC54B8C);
  static const Color boysenberry = Color(0xFF873260);
  static const Color grape = Color(0xFF6F2DA8);
  static const Color eggplant = Color(0xFF614051);
  static const Color wisteria = Color(0xFFC9A0DC);
  static const Color iris = Color(0xFF5A4FCF);
  static const Color heather = Color(0xFFB7C3D0);
  static const Color byzantium = Color(0xFF702963);

  //Main Theme Colors

  static const Color red = Color(0xFFDC0000);
  static const Color yellowTheme = Color(0xFFFFDB89);
  static const Color maroon = Color(0xFF850000);
  static const Color kids = Color(0xFFFFF6C3);

  // ==========================================
  // SEMANTIC DESIGN TOKENS (Brand System)
  // ------------------------------------------
  // Single source of truth for the redesigned UI. Always prefer these
  // tokens over raw color names above so the app stays visually cohesive.
  // ==========================================

  /// Primary brand color — the app identity (red).
  static const Color brandPrimary = Color(0xFFDC0000);

  /// Darker brand shade for gradients, pressed states and depth.
  static const Color brandPrimaryDark = Color(0xFF9E0000);

  /// Lighter brand shade for subtle highlights.
  static const Color brandPrimaryLight = Color(0xFFFF4D3D);

  // ==========================================
  // THEME-AWARE NEUTRAL TOKENS (light / dark)
  // ------------------------------------------
  // These resolve at runtime based on [brightness]. The app sets [brightness]
  // and remounts on theme change (see MainApp), so every widget reading these
  // getters repaints with the correct palette. Brand & status colours stay
  // fixed (const) — only neutrals/surfaces/text/borders flip for dark mode.
  // ==========================================

  /// Current app brightness. Set by the root before building MaterialApp.
  static Brightness brightness = Brightness.light;
  static bool get isDark => brightness == Brightness.dark;

  static Color _pick(Color light, Color dark) => isDark ? dark : light;

  /// Brand red tuned for *text & icons sitting on a surface*, adapting per theme.
  /// The base [brandPrimary] (#DC0000) is too dark to read on dark surfaces, so
  /// dark mode uses a brighter red. Use this for red labels/numbers/dots; keep
  /// [brandPrimary] for solid fills (buttons, selected chips) where text sits on
  /// top of it.
  static Color get brandText =>
      _pick(brandPrimary, const Color(0xFFFF5A4F));

  /// Soft red-tinted surface for chips, badges and highlighted cards.
  static Color get brandSurface =>
      _pick(const Color(0xFFFFF1EF), const Color(0xFF36211F));

  /// Even softer brand wash for large section backgrounds.
  static Color get brandSurfaceAlt =>
      _pick(const Color(0xFFFFF7F5), const Color(0xFF2A201F));

  // Surfaces & backgrounds
  static Color get background =>
      _pick(const Color(0xFFF6F7F9), const Color(0xFF121316));
  static Color get surface =>
      _pick(const Color(0xFFFFFFFF), const Color(0xFF1C1E21));
  static Color get surfaceMuted =>
      _pick(const Color(0xFFF1F3F6), const Color(0xFF2A2D31));

  // Text
  static Color get textPrimary =>
      _pick(const Color(0xFF1A1C1E), const Color(0xFFF1F2F4));
  static Color get textSecondary =>
      _pick(const Color(0xFF5C636E), const Color(0xFFAEB4BD));
  static Color get textTertiary =>
      _pick(const Color(0xFF9AA0A6), const Color(0xFF7C828B));

  // Borders & dividers
  static Color get borderSubtle =>
      _pick(const Color(0xFFEDEFF2), const Color(0xFF2C2F34));
  static Color get borderDefault =>
      _pick(const Color(0xFFE1E4E9), const Color(0xFF3A3E44));

  // Status colors (kept neutral and modern)
  static const Color success = Color(0xFF1FA971);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ==========================================
  // THEME-AWARE STATUS TINTS (light / dark)
  // ------------------------------------------
  // Soft surfaces/borders/text for banners, validation boxes and status chips.
  // Replace raw `Colors.green.shade50/200` etc. with these so green/orange
  // chrome reads correctly on dark backgrounds too.
  // ==========================================
  static Color get successSurface =>
      _pick(const Color(0xFFEAF7F0), const Color(0xFF153A2C));
  static Color get successBorder =>
      _pick(const Color(0xFFB6E3CD), const Color(0xFF2C6B50));
  static Color get successText =>
      _pick(const Color(0xFF12805A), const Color(0xFF4FD6A0));

  static Color get warningSurface =>
      _pick(const Color(0xFFFDF3E5), const Color(0xFF3A2C12));
  static Color get warningBorder =>
      _pick(const Color(0xFFF6D6A4), const Color(0xFF6E5421));
  static Color get warningText =>
      _pick(const Color(0xFFB45309), const Color(0xFFE3A33B));

  /// Canonical brand gradient (top-left → bottom-right) for headers & hero cards.
  static const List<Color> brandGradient = [
    Color(0xFFE7140C),
    Color(0xFFC10000),
    Color(0xFF9E0000),
  ];
}
