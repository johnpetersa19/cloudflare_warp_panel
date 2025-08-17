// language_selector.dart

import 'package:flutter/material.dart';
import 'package:cloudflare_warp_panel/l10n/app_localizations.dart';


typedef ChangeLocaleCallback = void Function(Locale? locale);

class LanguageSelector extends StatelessWidget {
  final ChangeLocaleCallback onChanged;

  const LanguageSelector({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language, color: Colors.grey),
      onSelected: (Locale? newLocale) {
        if (newLocale != null) {
          onChanged(newLocale);
        }
      },
      itemBuilder: (BuildContext context) {
        return AppLocalizations.supportedLocales.map((Locale locale) {
          return PopupMenuItem<Locale>(
            value: locale,
            child: Text(
              locale.languageCode.toUpperCase(),
            ),
          );
        }).toList();
      },

      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}

