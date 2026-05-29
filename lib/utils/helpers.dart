import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart';

/// مجموعة من الدوال المساعدة
class Helpers {
  /// تنسيق التاريخ بشكل عربي
  static String formatDate(DateTime date) {
    final formatter = intl.DateFormat('yyyy/MM/dd', 'ar');
    return formatter.format(date);
  }

  /// تنسيق التاريخ والوقت بشكل عربي
  static String formatDateTime(DateTime date) {
    final formatter = intl.DateFormat('yyyy/MM/dd - hh:mm a', 'ar');
    return formatter.format(date);
  }

  /// تنسيق رقم الهاتف اليمني
  static String formatPhoneNumber(String phoneNumber) {
    // إزالة جميع الرموز والمسافات
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // إذا كان الرقم يبدأ بـ 967، نضيف +
    if (cleanNumber.startsWith('967')) {
      return '+$cleanNumber';
    }
    
    // إذا كان الرقم يبدأ بـ 00967، نستبدلها بـ +967
    if (cleanNumber.startsWith('00967')) {
      return '+${cleanNumber.substring(2)}';
    }
    
    // إذا كان الرقم يبدأ بـ 7، نضيف +967
    if (cleanNumber.startsWith('7') && cleanNumber.length == 9) {
      return '+967$cleanNumber';
    }
    
    return phoneNumber;
  }

  /// تنسيق رقم الهاتف للعرض فقط — بدون رمز الدولة (مثل: +967777123456 → 777123456)
  /// يُستخدم في كل أماكن عرض الأرقام؛ أما الاتصال/واتساب فيستخدمان الرقم الكامل.
  static String displayPhoneNumber(String phoneNumber) {
    var n = phoneNumber.replaceAll(RegExp(r'[\s\-]'), '').trim();
    if (n.startsWith('+967')) {
      n = n.substring(4);
    } else if (n.startsWith('00967')) {
      n = n.substring(5);
    } else if (n.startsWith('967') && n.length > 9) {
      n = n.substring(3);
    }
    return n;
  }

  /// إجراء مكالمة هاتفية
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final formattedNumber = formatPhoneNumber(phoneNumber);
    final uri = Uri.parse('tel:$formattedNumber');
    
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// فتح محادثة واتساب
  static Future<bool> openWhatsApp(String phoneNumber, {String? message}) async {
    final formattedNumber = formatPhoneNumber(phoneNumber);
    // إزالة رمز + و 00 من الرقم
    final cleanNumber = formattedNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    final encodedMessage = Uri.encodeComponent(message ?? '');
    final uri = Uri.parse('https://wa.me/$cleanNumber?text=$encodedMessage');
    
    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
    return false;
  }

  /// حساب الفرق بين تاريخين بالأيام
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// التحقق من إمكانية التبرع بناءً على آخر تاريخ تبرع
  static bool canDonate(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return true;
    
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    return lastDonationDate.isBefore(sixMonthsAgo);
  }

  /// حساب الأيام المتبقية حتى يمكن التبرع
  static int? daysUntilCanDonate(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return 0;
    
    final sixMonthsFromLast = lastDonationDate.add(const Duration(days: 180));
    if (DateTime.now().isAfter(sixMonthsFromLast)) return 0;
    
    return daysBetween(DateTime.now(), sixMonthsFromLast);
  }

  /// الحصول على الفصائل المتوافقة مع فصيلة معينة
  static List<String> getCompatibleBloodTypes(String bloodType) {
    // جدول التوافق
    const compatibility = {
      'A+': ['A+', 'A-', 'O+', 'O-'],
      'A-': ['A-', 'O-'],
      'B+': ['B+', 'B-', 'O+', 'O-'],
      'B-': ['B-', 'O-'],
      'AB+': ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], // يستقبل من الجميع
      'AB-': ['A-', 'B-', 'AB-', 'O-'],
      'O+': ['O+', 'O-'],
      'O-': ['O-'], // يستقبل من O- فقط
    };
    
    return compatibility[bloodType] ?? [bloodType];
  }

  /// تحويل الجنس إلى نص عربي
  static String genderToArabic(String gender) {
    switch (gender) {
      case 'male':
        return 'ذكر';
      case 'female':
        return 'أنثى';
      default:
        return gender;
    }
  }

  /// تحويل النص العربي إلى جنس
  static String arabicToGender(String arabic) {
    switch (arabic) {
      case 'ذكر':
        return 'male';
      case 'أنثى':
        return 'female';
      default:
        return arabic;
    }
  }

  /// التحقق من أن التطبيق يعمل على Android
  static bool get isAndroid {
    // يمكن استخدام Platform.isAndroid من dart:io
    // لكن هنا نستخدم طريقة بسيطة
    return true; // يمكن تحسينها لاحقاً
  }

  /// التحقق من أن التطبيق يعمل على iOS
  static bool get isIOS {
    return false; // يمكن تحسينها لاحقاً
  }

  /// عرض رسالة نجاح
  static void showSuccessMessage(String message) {
    // سيتم تنفيذها باستخدام SnackBar في الواجهة
  }

  /// عرض رسالة خطأ
  static void showErrorMessage(String message) {
    // سيتم تنفيذها باستخدام SnackBar في الواجهة
  }
}

