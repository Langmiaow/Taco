import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taco/l10n/app_localizations.dart';


class ShareInfoPage extends StatefulWidget {
  final String pin;

  const ShareInfoPage({super.key, required this.pin});

  @override
  State<ShareInfoPage> createState() => _ShareInfoPage();
}

class _ShareInfoPage extends State<ShareInfoPage> {
  bool isCopied = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 237, 237, 237),
      body: Column(
        children: [
          const SizedBox(height: 45),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 80,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  Text(t.share, style: TextStyle(fontSize: 32)),
                  const Spacer(),
                  Material(
                    shape: const CircleBorder(),
                    color: Colors.white,
                    child: IconButton(
                      onPressed: isCopied
                          ? null
                          : () {
                              Clipboard.setData(
                                ClipboardData(text: widget.pin),
                              );
                              HapticFeedback.mediumImpact();
                              setState(() {
                                isCopied = true;
                              });
                            },
                      icon: Icon(
                        isCopied
                            ?Icons.done
                            :Icons.copy_rounded
                      ),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    shape: const CircleBorder(),
                    color: Colors.white,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              t.shareHint,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      widget.pin[index],
                      style: const TextStyle(
                        color: Color.fromARGB(255, 40, 110, 240),
                        fontSize: 48,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
