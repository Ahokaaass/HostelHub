import 'package:flutter/material.dart';

const _kBlue      = Color(0xFF1565C0);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBlueBorder= Color(0xFFBBD0F8);

class ServiceTile extends StatelessWidget {
  final IconData icon;
  final String   title;
  final VoidCallback onTap;

  // Optional overrides for special tiles (e.g. alerts in orange)
  final Color? accentColor;
  final Color? bgColor;

  const ServiceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.accentColor,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = accentColor ?? _kBlue;
    final Color bg     = bgColor     ?? _kBlueTint;

    return Material(
      color        : Colors.transparent,
      borderRadius : BorderRadius.circular(20),
      child: InkWell(
        onTap        : onTap,
        borderRadius : BorderRadius.circular(20),
        splashColor  : accent.withOpacity(0.08),
        highlightColor: accent.withOpacity(0.04),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kBlueBorder, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color     : Color(0x0C1565C0),
                blurRadius: 10,
                offset    : Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icon box ──────────────────────────────────────────────
              Container(
                width : 54,
                height: 54,
                decoration: BoxDecoration(
                  color        : Colors.white,
                  borderRadius : BorderRadius.circular(16),
                  boxShadow    : [
                    BoxShadow(
                      color     : accent.withOpacity(0.15),
                      blurRadius: 10,
                      offset    : const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 26, color: accent),
              ),

              const SizedBox(height: 12),

              // ── Label ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines : 2,
                  overflow : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize  : 12,
                    fontWeight: FontWeight.w700,
                    color     : accent,
                    height    : 1.3,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}