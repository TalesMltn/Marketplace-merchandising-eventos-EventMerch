import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/merch_sku.dart';
import '../models/merch_variant.dart';

final supabase = Supabase.instance.client;

class SupabaseService {
  // Todos los eventos
  static Future<List<Event>> getEvents() async {
    final response = await supabase
        .from('events')
        .select()
        .eq('active', true)
        .order('date', ascending: true);

    return (response as List).map((e) => Event.fromJson(e)).toList();
  }

  // Merch por evento
  static Future<List<MerchSku>> getMerchByEvent(String eventId) async {
    final response = await supabase
        .from('merch_skus')
        .select()
        .eq('event_id', eventId)
        .eq('active', true);

    return (response as List).map((e) => MerchSku.fromJson(e)).toList();
  }

  // Variantes de un SKU
  static Future<List<MerchVariant>> getVariants(String skuId) async {
    final response =
    await supabase.from('merch_variants').select().eq('sku_id', skuId);

    return (response as List).map((e) => MerchVariant.fromJson(e)).toList();
  }
}