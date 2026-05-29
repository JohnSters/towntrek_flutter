import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen QR scanner that returns the first decoded string (expected to be
/// a TownTrek TREK access code) via [Navigator.pop]. Returns `null` if the user
/// dismisses the scanner without scanning.
class ScanAccessCodeScreen extends StatefulWidget {
  const ScanAccessCodeScreen({super.key});

  @override
  State<ScanAccessCodeScreen> createState() => _ScanAccessCodeScreenState();
}

class _ScanAccessCodeScreenState extends State<ScanAccessCodeScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw != null && raw.isNotEmpty) {
        _handled = true;
        Navigator.of(context).pop(raw.toUpperCase());
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan TownTrek code'),
        actions: [
          IconButton(
            tooltip: 'Toggle torch',
            icon: const Icon(Icons.flashlight_on_rounded),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.no_photography_outlined,
                        color: Colors.white70,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Camera unavailable. You can type your code instead.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Enter code manually'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Text(
                'Point your camera at the QR code on the My Devices page.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
