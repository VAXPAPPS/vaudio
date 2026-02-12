import 'package:flutter/material.dart';
import '../../../../core/colors/vaxp_colors.dart';
import 'package:venom_config/venom_config.dart';

/// صفحة الإعدادات
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ignore: unused_field
  final _config = VenomConfig();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.settings_rounded, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // قسم المظهر
          _SectionTitle('Appearance'),
          const SizedBox(height: 12),
          _ColorPickerTile(
            title: 'Background Color',
            subtitle: 'Change the app background color',
            icon: Icons.palette_outlined,
            configKey: 'system.background_color',
          ),
          const SizedBox(height: 8),
          _ColorPickerTile(
            title: 'Text Color',
            subtitle: 'Change the text color',
            icon: Icons.text_fields_rounded,
            configKey: 'system.text_color',
          ),

          const SizedBox(height: 32),

          // قسم الاختصارات
          _SectionTitle('Keyboard Shortcuts'),
          const SizedBox(height: 12),
          _ShortcutInfo('Space', 'Play / Pause'),
          _ShortcutInfo('← →', 'Seek -/+ 5 seconds'),
          _ShortcutInfo('↑ ↓', 'Volume Up / Down'),
          _ShortcutInfo('M', 'Mute / Unmute'),
          _ShortcutInfo('N', 'Next Track'),
          _ShortcutInfo('P', 'Previous Track'),

          const SizedBox(height: 32),

          // معلومات
          _SectionTitle('About'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.04),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Venom Audio Player',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 0.1.0',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Part of the VAXP Ecosystem',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.4),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: VaxpColors.secondary,
        letterSpacing: 1,
      ),
    );
  }
}

class _ColorPickerTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String configKey;

  const _ColorPickerTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.configKey,
  });

  @override
  Widget build(BuildContext context) {
    final config = VenomConfig();
    final currentHex = config.getAll()[configKey] as String? ?? '#000000';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.04),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.white.withOpacity(0.6)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          // عرض اللون الحالي
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _parseColor(currentHex),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    return Colors.black;
  }
}

class _ShortcutInfo extends StatelessWidget {
  final String keys;
  final String action;
  const _ShortcutInfo(this.keys, this.action);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              keys,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            action,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
