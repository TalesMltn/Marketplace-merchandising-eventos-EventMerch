// lib/screens/success_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SuccessScreen extends StatelessWidget {
  final String codigo;
  final double total;
  final String deliveryOption; // 'pickup' o 'delivery'
  final String? trackingNumber;

  const SuccessScreen({
    super.key,
    required this.codigo,
    required this.total,
    required this.deliveryOption,
    this.trackingNumber,
  });

  // GENERAR PDF + QR Y COMPARTIR
  Future<void> _generateAndSharePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text("¡PAGO EXITOSO!", style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 30),
              pw.Text("Código de pedido:", style: const pw.TextStyle(fontSize: 18)),
              pw.Text(codigo, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.SizedBox(
                width: 200,
                height: 200,
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: codigo,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text("Total pagado: S/ ${total.toStringAsFixed(2)}", style: const pw.TextStyle(fontSize: 22)),
              pw.SizedBox(height: 15),
              pw.Text(
                deliveryOption == 'pickup' ? "Recogerás en el evento" : "Envío a domicilio",
                style: pw.TextStyle(
                  fontSize: 20,
                  color: deliveryOption == 'pickup' ? PdfColors.orange : PdfColors.blue,
                ),
              ),
              if (trackingNumber != null) ...[
                pw.SizedBox(height: 10),
                pw.Text("Tracking: $trackingNumber", style: const pw.TextStyle(fontSize: 18)),
              ],
              pw.SizedBox(height: 30),
              pw.Text("¡Gracias por tu compra!", style: const pw.TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/comprobante_$codigo.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "¡Aquí tienes tu comprobante! Código: $codigo",
      subject: "Comprobante de pago - $codigo",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, size: 130, color: Colors.green),
                const SizedBox(height: 30),
                Text(
                  "¡PAGO EXITOSO!",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const Text("Tu código de pedido:", style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 8),
                SelectableText(
                  codigo,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 3),
                ),
                const SizedBox(height: 20),

                // QR en pantalla
                QrImageView(
                  data: codigo,
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 30),

                // Método de entrega
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: deliveryOption == 'pickup' ? Colors.orange.shade50 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: deliveryOption == 'pickup' ? Colors.orange.shade400 : Colors.blue.shade400,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        deliveryOption == 'pickup' ? Icons.location_on : Icons.local_shipping,
                        size: 40,
                        color: deliveryOption == 'pickup' ? Colors.orange.shade700 : Colors.blue.shade700,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        deliveryOption == 'pickup' ? "Recogerás en el evento" : "Envío a domicilio",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: deliveryOption == 'pickup' ? Colors.orange.shade900 : Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),

                if (trackingNumber != null) ...[
                  const SizedBox(height: 25),
                  const Text("Número de seguimiento:", style: TextStyle(fontSize: 17, color: Colors.grey)),
                  const SizedBox(height: 8),
                  SelectableText(
                    trackingNumber!,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.purple),
                  ),
                ],

                const SizedBox(height: 40),
                Text(
                  "Total pagado: S/ ${total.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 40),

                // BOTÓN COMPARTIR PDF
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share, size: 32),
                    label: const Text("Enviar comprobante por WhatsApp", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366), // Verde WhatsApp
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => _generateAndSharePdf(context),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home, size: 28),
                    label: const Text("Volver al inicio", style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}