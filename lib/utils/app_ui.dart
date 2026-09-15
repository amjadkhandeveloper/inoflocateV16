import 'package:flutter/material.dart';

/// Shared visual language extracted from the Sequel fleet dashboard.
class AppUi {
  AppUi._();

  static const Color pageBgLight = Color(0xFFF4F6F9);
  static const Color inkLight = Color(0xFF1E293B);
  static const Color mutedLight = Color(0xFF64748B);
  static const Color lineLight = Color(0xFFE2E8F0);
  static const Color cardLight = Colors.white;

  static const Color pageBgDark = Color(0xFF0F172A);
  static const Color inkDark = Color(0xFFF8FAFC);
  static const Color mutedDark = Color(0xFF94A3B8);
  static const Color lineDark = Color(0xFF334155);
  static const Color cardDark = Color(0xFF1E293B);

  static const Color accent = Color(0xFF2563EB);
  static const double radius = 14;
  static const double radiusSm = 10;
  static const double iconChipRadius = 8;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color pageBg(BuildContext context) =>
      isDark(context) ? pageBgDark : pageBgLight;

  static Color ink(BuildContext context) =>
      isDark(context) ? inkDark : inkLight;

  static Color muted(BuildContext context) =>
      isDark(context) ? mutedDark : mutedLight;

  static Color line(BuildContext context) =>
      isDark(context) ? lineDark : lineLight;

  static Color cardColor(BuildContext context) =>
      isDark(context) ? cardDark : cardLight;

  static BoxDecoration cardDecoration(BuildContext context) => BoxDecoration(
        color: cardColor(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: line(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark(context) ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static Widget card({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? borderColor,
    Color? fill,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: fill ?? cardColor(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? line(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark(context) ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  static TextStyle titleStyle(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ink(context),
      );

  static TextStyle brandTitle(BuildContext context) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: ink(context),
        letterSpacing: -0.4,
      );

  static TextStyle subtitle(BuildContext context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: muted(context),
      );

  static TextStyle mutedStyle(BuildContext context) => TextStyle(
        fontSize: 12,
        color: muted(context),
      );

  static TextStyle sectionLabel(BuildContext context) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: ink(context),
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ink(context),
      );

  static TextStyle fieldLabel(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: muted(context),
      );

  static InputDecoration inputDecoration({
    required BuildContext context,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusSm),
      borderSide: BorderSide(color: line(context)),
    );
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 13, color: muted(context)),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: pageBg(context),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: accent, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.4),
      ),
    );
  }

  static Widget iconChip({
    required IconData icon,
    Color color = accent,
    double size = 40,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(iconChipRadius),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }

  static Widget primaryButton({
    required String title,
    required VoidCallback? onPressed,
    bool loading = false,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: accent.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static Widget ghostButton({
    required BuildContext context,
    required String title,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: ink(context),
          side: BorderSide(color: line(context)),
          backgroundColor: cardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: ink(context)),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ink(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const String logoAsset = 'assets/images/ic_infolocate.png';

  static Widget brandMark({double size = 56}) {
    return Image.asset(
      logoAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.near_me_rounded, size: size * 0.5, color: accent),
      ),
    );
  }

  static Widget pageHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
    VoidCallback? onBack,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 12, 8),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back_rounded, color: ink(context)),
            )
          else
            const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle(context)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: mutedStyle(context)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static AppBar appBar({
    required BuildContext context,
    required String title,
    String? subtitle,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = false,
  }) {
    return AppBar(
      backgroundColor: cardColor(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      foregroundColor: ink(context),
      iconTheme: IconThemeData(color: ink(context)),
      title: subtitle == null
          ? Text(title, style: titleStyle(context))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle(context)),
                Text(subtitle, style: mutedStyle(context)),
              ],
            ),
      leading: leading,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: line(context)),
      ),
    );
  }

  static double bottomInset(BuildContext context, {double extra = 16}) {
    return extra + MediaQuery.paddingOf(context).bottom;
  }
}

/// Shared auth page shell: brand, title, form card, footer.
class AppAuthScaffold extends StatelessWidget {
  const AppAuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppUi.pageBg(context),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      AppUi.brandMark(size: 88),
                      const SizedBox(height: 16),
                      Text('InfoLocate', style: AppUi.brandTitle(context)),
                      const SizedBox(height: 6),
                      Text(title, style: AppUi.titleStyle(context)),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppUi.subtitle(context),
                      ),
                      const SizedBox(height: 28),
                      AppUi.card(
                        context: context,
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: footer!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
