// lib/utils/pdf_generator.dart
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfGenerator {
  static Future<File> generateOrderPdf({
    required String orderCode,
    required double total,
    required String customerName,
    required String dni,
    required String phone,
    required String deliveryOption,
    required String? pickupCode,
    required String? trackingNumber,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                "¡PAGO EXITOSO!",
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold, // CORREGIDO
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text("Código: $orderCode", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("Cliente: $customerName"),
            pw.Text("DNI: $dni"),
            pw.Text("Teléfono: $phone"),
            pw.SizedBox(height: 15),
            pw.Text(
              "Entrega: ${deliveryOption == 'pickup' ? 'Recogida en evento' : 'Envío a domicilio'}",
              style: const pw.TextStyle(fontSize: 16),
            ),
            if (pickupCode != null)
              pw.Text("Código de recogida: $pickupCode", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            if (trackingNumber != null)
              pw.Text("Tracking: $trackingNumber", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("Detalles del pedido:", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            ...items.map((item) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Text(
                "• ${item['name']} x${item['quantity']} - S/ ${(item['price'] * item['quantity']).toStringAsFixed(2)}",
              ),
            )),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                "TOTAL: S/ ${total.toStringAsFixed(2)}",
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Center(
              child: pw.Text(
                "¡Gracias por tu compra!",
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
            ),
          ],
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/comprobante_$orderCode.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}