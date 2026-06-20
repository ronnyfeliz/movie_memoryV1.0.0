import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.about,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
      ),
      body: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          );
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          physics: const BouncingScrollPhysics(),
          children: [
            // App Identity Header (Wow-factor design)
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primaryContainer,
                          cs.primary.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: isDark ? 0.3 : 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'logo/Logo_MovieMemoryApp.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.video_library_rounded,
                          size: 60,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'MovieMemory',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      'Versión 1.0.0',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Card 1: Descripción Corta (Premium Glassmorphism-like card)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
              ),
              color: cs.surfaceContainerLow.withValues(alpha: 0.8),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.info_outline_rounded, color: cs.primary, size: 28),
                    const SizedBox(height: 12),
                    Text(
                      'Plataforma para descubrir, organizar y disfrutar contenido multimedia.',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Card 2: Información de la Aplicación
            _buildSectionHeader(cs, 'Información de la aplicación'),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              color: cs.surfaceContainerLow,
              child: const Column(
                children: [
                  _InfoRow(
                    icon: Icons.code_rounded,
                    label: 'Desarrollador',
                    value: 'Innovatech',
                    isLast: false,
                  ),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Fecha de lanzamiento',
                    value: '16/06/2026',
                    isLast: false,
                  ),
                  _InfoRow(
                    icon: Icons.alternate_email_rounded,
                    label: 'Email de soporte',
                    value: 'innovatech.1801@gmail.com',
                    isLast: false,
                  ),
                  _InfoRow(
                    icon: Icons.api_rounded,
                    label: 'Proveedor de Datos',
                    value: 'TMDb API',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card 3: Créditos y Atribuciones
            _buildSectionHeader(cs, 'Créditos'),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              color: cs.surfaceContainerLow,
              child: const Column(
                children: [
                  _InfoRow(
                    icon: Icons.audiotrack_rounded,
                    label: 'Efectos de sonido',
                    value: 'FreeSound',
                    subtitle: 'Sonidos y efectos de audio obtenidos de FreeSound.',
                    isLast: false,
                  ),
                  _InfoRow(
                    icon: Icons.palette_outlined,
                    label: 'Diseño e Iconografía',
                    value: 'Material Design 3',
                    subtitle: 'Iconos y recursos visuales basados en Material Design.',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '© 2026 Innovatech. Todos los derechos reservados.',
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hecho con ♥ para amantes del cine',
                    style: TextStyle(
                      color: cs.primary.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ColorScheme cs, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: TextStyle(
          color: cs.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: cs.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.85),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ] else
                      Text(
                        value,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Divider(color: cs.outlineVariant.withValues(alpha: 0.4), height: 1),
          ),
      ],
    );
  }
}
