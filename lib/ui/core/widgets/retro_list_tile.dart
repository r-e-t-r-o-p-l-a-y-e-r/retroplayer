import 'package:flutter/material.dart';
import 'package:retroplayer/ui/core/retro/retro_palette.dart';
import 'package:retroplayer/ui/core/retro/retro_decorations.dart';
import 'package:retroplayer/ui/core/retro/retro_spacing.dart';

/// Styled list row with optional playing highlight strip.
class RetroListTile extends StatelessWidget {
  const RetroListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.dense = false,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final palette = RetroPalette.of(context);
    final minHeight = dense ? 48.0 : RetroSpacing.listRowHeight;

    return Material(
      color: selected ? palette.playingHighlight : Colors.transparent,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selected)
              Container(
                width: 3,
                color: palette.accent,
              ),
            Expanded(
              child: InkWell(
                onTap: onTap,
                onLongPress: onLongPress,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        if (leading != null) ...[
                          leading!,
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DefaultTextStyle(
                                style: TextStyle(
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: selected
                                      ? palette.accent
                                      : palette.textPrimary,
                                ),
                                child: title,
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                DefaultTextStyle(
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: palette.textMuted,
                                  ),
                                  child: subtitle!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Rounded square icon container for folder/album rows.
class RetroIconChip extends StatelessWidget {
  const RetroIconChip({
    super.key,
    required this.icon,
    this.color,
    this.highlight = false,
  });

  final IconData icon;
  final Color? color;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final palette = RetroPalette.of(context);
    return Container(
      width: RetroSpacing.iconChipSize,
      height: RetroSpacing.iconChipSize,
      decoration: RetroDecorations.iconChip(palette),
      child: Icon(
        icon,
        size: 22,
        color: highlight ? palette.accent : (color ?? palette.textSecondary),
      ),
    );
  }
}
