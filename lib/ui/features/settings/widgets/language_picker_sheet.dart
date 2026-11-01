import 'package:flutter/material.dart';
import 'package:retroplayer/domain/models/locale_preference.dart';
import 'package:retroplayer/l10n/app_locale_catalog.dart';
import 'package:retroplayer/l10n/app_localizations.dart';
import 'package:retroplayer/ui/core/keyboard/desktop_host.dart';

/// Modal list of app languages (System first, then catalog endonyms).
Future<void> showLanguagePickerSheet({
  required BuildContext context,
  required LocalePreference selected,
  required ValueChanged<LocalePreference> onSelected,
}) {
  final l10n = AppLocalizations.of(context);
  final useBottomSheet = !isDesktopHost();

  Widget buildList(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        _LanguagePickerTile(
          listTileKey: const ValueKey('language-option-system'),
          label: l10n.languageSystem,
          selected: selected.isSystem,
          onTap: () {
            onSelected(LocalePreference.system);
            Navigator.pop(context);
          },
        ),
        for (final entry in AppLocaleCatalog.pickerEntries(
          Localizations.localeOf(context),
        ))
          _LanguagePickerTile(
            listTileKey: ValueKey('language-option-${entry.storageCode}'),
            label: entry.endonym,
            selected: !selected.isSystem &&
                selected.languageCode == entry.storageCode,
            onTap: () {
              onSelected(LocalePreference.language(entry.storageCode));
              Navigator.pop(context);
            },
          ),
      ],
    );
  }

  if (useBottomSheet) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final maxHeight = MediaQuery.sizeOf(context).height * 0.75;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    l10n.language,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Flexible(child: buildList(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.language),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: buildList(context),
      ),
    ),
  );
}

class _LanguagePickerTile extends StatelessWidget {
  const _LanguagePickerTile({
    required this.listTileKey,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Key listTileKey;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: listTileKey,
      title: Text(label),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}
