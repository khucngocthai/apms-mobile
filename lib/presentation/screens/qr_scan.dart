import 'dart:developer';
import 'dart:io';

import 'package:apms_mobile/bloc/repositories/qr_repo.dart';
import 'package:apms_mobile/main.dart';
import 'package:apms_mobile/models/qr_model.dart';
import 'package:apms_mobile/result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScan extends StatefulWidget {
  const QRScan({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScan();
}

class _QRScan extends State<QRScan> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? code;
  Qr? qr;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (result != null)
                    Text(
                        'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  else
                    const Text('Scan a code'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    var navigate = Navigator.of(context);
    var messenger = ScaffoldMessenger.of(context);
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      result = scanData;
      code = result!.code!.replaceAll("True", "true");
      qr = qrModelFromJson(code!.replaceAll("False", "false"));
      final QrRepo repo = QrRepo();
      if (!qr!.checkin!) {
        bool res = await repo.checkIn(qr!);
        if (res) {
          navigate.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MyHome(
                  tabIndex: 1,
                  headerTabIndex: 1,
                ),
              ),
              (route) => false);
        } else {
          messenger.showSnackBar(const SnackBar(
            content: Text('Checkin failed!'),
          ));
          controller.resumeCamera();
        }
      } else {
        bool res = await repo.checkOut(qr!);
        if (res) {
          navigate.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MyHome(
                  tabIndex: 1,
                  headerTabIndex: 2,
                ),
              ),
              (route) => false);
        } else {
          messenger.showSnackBar(const SnackBar(
            content: Text('Checkout failed!'),
          ));
          controller.resumeCamera();
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    } else {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
