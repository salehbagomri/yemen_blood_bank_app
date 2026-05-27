import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../config/supabase_config.dart';

/// خدمة مراقبة حالة الاتصال بالإنترنت
/// تتحقق عبر الـ Cloudflare Worker بدلاً من السيرفرات الافتراضية
/// (التي قد تكون محجوبة في اليمن)
class ConnectivityService {
  late final InternetConnectionChecker _checker;

  StreamSubscription<InternetConnectionStatus>? _subscription;
  bool _isConnected = true;
  final _controller = StreamController<bool>.broadcast();

  // Getters
  bool get isConnected => _isConnected;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  ConnectivityService() {
    // إنشاء instance مخصص يتحقق عبر الـ Worker (غير محجوب)
    _checker = InternetConnectionChecker.instance
      ..addresses = [
        // التحقق عبر الـ Cloudflare Worker الخاص بنا
        AddressCheckOption(
          uri: Uri.parse('${SupabaseConfig.activeSupabaseUrl}/rest/v1/'),
          timeout: const Duration(seconds: 5),
        ),
        // Cloudflare DNS (عادة غير محجوب)
        AddressCheckOption(
          uri: Uri.parse('https://one.one.one.one'),
          timeout: const Duration(seconds: 5),
        ),
        // Google DNS
        AddressCheckOption(
          uri: Uri.parse('https://dns.google'),
          timeout: const Duration(seconds: 5),
        ),
      ];
  }

  /// بدء مراقبة الاتصال
  Future<void> initialize() async {
    // فحص أولي سريع عبر HTTP بدلاً من المكتبة (أسرع)
    _isConnected = await _quickCheck();

    _subscription = _checker.onStatusChange.listen((status) {
      final connected = status == InternetConnectionStatus.connected;
      if (_isConnected != connected) {
        _isConnected = connected;
        _controller.add(_isConnected);
        debugPrint(
          _isConnected ? '🟢 Network: Connected' : '🔴 Network: Disconnected',
        );
      }
    });

    debugPrint('✅ ConnectivityService: initialized (connected=$_isConnected)');
  }

  /// فحص سريع عبر HTTP للـ Worker
  Future<bool> _quickCheck() async {
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(
        Uri.parse('${SupabaseConfig.activeSupabaseUrl}/rest/v1/'),
      );
      request.headers.set('apikey', SupabaseConfig.supabaseAnonKey);
      final response = await request.close();
      client.close();
      return response.statusCode < 500;
    } catch (e) {
      debugPrint('⚠️ Quick connectivity check failed: $e');
      return false;
    }
  }

  /// فحص الاتصال مرة واحدة
  Future<bool> checkConnection() async {
    _isConnected = await _quickCheck();
    return _isConnected;
  }

  /// إيقاف المراقبة
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
