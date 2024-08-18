import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../main.dart';
import '../services/auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const QRScannerPage(),
              ),
            );
          },
          child: const Text('ログインする'),
        ),
      ),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String scannedValue = '';
  String errorMessage = '';
  bool isLoading = false;

  final AuthService _authService = AuthService();

  Future<void> _handleScannedValue(String value) async {
    setState(() {
      scannedValue = value;
      isLoading = true;
      errorMessage = '';
    });

    final isValid = await _authService.verifyToken(scannedValue);
    if (isValid) {
      await _authService.saveLoginStatus(scannedValue);

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const TopPage()),
          (route) => false,
        );
      }
    } else {
      setState(() {
        errorMessage = '無効なトークンです。';
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isLoading)
              const CircularProgressIndicator()
            else
              SizedBox(
                height: 600,
                child: MobileScanner(
                  controller: MobileScannerController(
                    detectionSpeed: DetectionSpeed.noDuplicates,
                  ),
                  onDetect: (capture) async {
                    final List<Barcode> barcodes = capture.barcodes;
                    final value =
                        barcodes.isNotEmpty ? barcodes[0].rawValue : null;
                    if (value != null) {
                      await _handleScannedValue(value);
                    }
                  },
                ),
              ),
            Text(
              scannedValue.isEmpty
                  ? 'ログイン用のQRコードをスキャンしてください。'
                  : 'QRコードを検知しました。',
              style: const TextStyle(fontSize: 15),
            ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            Text(scannedValue.isEmpty ? "" : "value: $scannedValue"),
          ],
        ),
      ),
    );
  }
}
