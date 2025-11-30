// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/cart_provider.dart';
import 'success_screen.dart';
import 'package:uuid/uuid.dart';
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _recogidaEnEvento = true;
  bool _aceptaTerminos = false;
  bool _procesando = false;

  @override
  void dispose() {
    _dniCtrl.dispose();
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final totalFinal = _recogidaEnEvento
        ? notifier.totalWithDiscount
        : notifier.totalWithDiscount + 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Datos de compra", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              TextFormField(
                controller: _dniCtrl,
                decoration: const InputDecoration(labelText: "DNI", border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return "DNI requerido";
                  if (v.length != 8 || !RegExp(r'^\d+$').hasMatch(v)) return "DNI inválido";
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: "Nombres y apellidos", border: OutlineInputBorder()),
                validator: (v) => v?.trim().isNotEmpty == true ? null : "Campo requerido",
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoCtrl,
                decoration: const InputDecoration(labelText: "Teléfono", border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) => (v?.length ?? 0) >= 9 ? null : "Mínimo 9 dígitos",
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email (opcional)", border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 30),
              const Text("Método de entrega", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              RadioListTile<bool>(
                title: const Text("Recogida en el evento (GRATIS)"),
                value: true,
                groupValue: _recogidaEnEvento,
                onChanged: (v) => setState(() => _recogidaEnEvento = v!),
              ),
              RadioListTile<bool>(
                title: const Text("Envío a domicilio (+ S/20)"),
                value: false,
                groupValue: _recogidaEnEvento,
                onChanged: (v) => setState(() => _recogidaEnEvento = v!),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(value: _aceptaTerminos, onChanged: (v) => setState(() => _aceptaTerminos = v!)),
                  const Expanded(child: Text("Acepto los términos y condiciones")),
                ],
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700),
                  onPressed: (_aceptaTerminos && !_procesando && cart.items.isNotEmpty)
                      ? () => _procesarPago(totalFinal)
                      : null,
                  child: _procesando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "PAGAR S/ ${totalFinal.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _procesarPago(double totalFinal) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _procesando = true);

    try {
      final cart = ref.read(cartProvider);

      // USAMOS SOLO LAS COLUMNAS QUE YA EXISTEN EN TU TABLA
      final response = await Supabase.instance.client
          .from('orders')
          .insert({
        'user_id': Supabase.instance.client.auth.currentUser?.id
            ?? const Uuid().v4(),   // ← UUID válido siempre
        'event_id': cart.items.isNotEmpty ? cart.items.first.eventId : null,
        'total_amount': totalFinal,
        'delivery_option': _recogidaEnEvento ? 'pickup' : 'delivery',
        'status': 'paid',
        'pickup_code': _recogidaEnEvento
            ? "PICK-${DateTime.now().millisecondsSinceEpoch % 100000}"
            : null,
      })
          .select()
          .single();

      // Limpiamos carrito
      ref.read(cartProvider.notifier).clear();

      // Códigos bonitos para el cliente
      final orderId = response['id'].toString().split('-').last.toUpperCase().substring(0, 8);
      final codigoVisible = "ORD-$orderId";
      final trackingNumber = _recogidaEnEvento ? null : "TRK-$orderId";

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessScreen(
            codigo: codigoVisible,
            total: totalFinal,
            deliveryOption: _recogidaEnEvento ? 'pickup' : 'delivery',
            trackingNumber: trackingNumber,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }
}