/// جميع النصوص الثابتة في التطبيق
class AppStrings {
  // اسم التطبيق
  static const String appName = 'بنك دم اليمن';
  static const String appNameEnglish = 'Yemen Blood Bank';
  
  // الصفحة الرئيسية
  static const String home = 'الرئيسية';
  static const String search = 'بحث';
  static const String addDonor = 'إضافة متبرع';
  static const String awareness = 'التوعية';
  static const String reportDonor = 'الإبلاغ عن رقم';
  
  // البحث
  static const String searchForDonors = 'البحث عن متبرعين';
  static const String selectBloodType = 'اختر فصيلة الدم';
  static const String selectDistrict = 'اختر المحافظة';
  static const String searchResults = 'نتائج البحث';
  static const String noDonorsFound = 'لا يوجد متبرعين';
  static const String noDonorsMessage = 'لم يتم العثور على متبرعين بهذه المواصفات';
  
  // فصائل الدم
  static const String bloodTypeA = 'A+';
  static const String bloodTypeANeg = 'A-';
  static const String bloodTypeB = 'B+';
  static const String bloodTypeBNeg = 'B-';
  static const String bloodTypeAB = 'AB+';
  static const String bloodTypeABNeg = 'AB-';
  static const String bloodTypeO = 'O+';
  static const String bloodTypeONeg = 'O-';
  
  // محافظات اليمن
  static const List<String> districts = [
    'أمانة العاصمة',
    'عدن',
    'تعز',
    'حضرموت',
    'الحديدة',
    'إب',
    'لحج',
    'أبين',
    'شبوة',
    'مأرب',
    'المهرة',
    'البيضاء',
    'الضالع',
    'الجوف',
    'حجة',
    'عمران',
    'صعدة',
    'ذمار',
    'المحويت',
    'ريمة',
    'أرخبيل سقطرى',
    'صنعاء',
  ];
  
  // خريطة المديريات التابعة لكل محافظة في اليمن
  static const Map<String, List<String>> governorateDistricts = {
    'أمانة العاصمة': ['السبعين', 'شعوب', 'معين', 'التحرير', 'الثورة', 'الصافية', 'صنعاء القديمة', 'الوحدة', 'آزال', 'بني الحارث'],
    'عدن': ['صيرة (كريتر)', 'التواهي', 'المعلا', 'خور مكسر', 'الشيخ عثمان', 'المنصورة', 'دار سعد', 'البريقة'],
    'تعز': ['القاهرة', 'المظفر', 'صالة', 'التعزية', 'شرعب السلام', 'شرعب الرونة', 'المخا', 'التربة', 'المواسط', 'خدير', 'ماوية', 'المعافر', 'حيفان'],
    'حضرموت': ['المكلا', 'سيئون', 'الشحر', 'تريم', 'شبام', 'القطن', 'غيل باوزير', 'دوعن', 'غيل بن يمين', 'الريدة وقصيعر'],
    'الحديدة': ['الحوك', 'الميناء', 'الحالي', 'باجل', 'بيت الفقية', 'زبيد', 'الجراحي', 'الخوخة', 'حيس', 'الدريهمي', 'المرواعة'],
    'إب': ['المشنة', 'الظهار', 'ذي السفال', 'السياني', 'جبلة', 'حبيش', 'بعدان', 'يريم', 'السدة', 'النادرة', 'العدين', 'حزم العدين'],
    'لحج': ['الحوطة', 'تبن', 'يافع (لبعوس)', 'ردفان', 'طور الباحة', 'القبيطة', 'المقاطرة', 'الملاح'],
    'أبين': ['زنجبار', 'خنفر (جعار)', 'لودر', 'مودية', 'المحفد', 'أحور', 'رصد'],
    'شبوة': ['عتق', 'بيحان', 'عسيلان', 'نصاب', 'حبان', 'ميفعة', 'الروضة', 'رضوم'],
    'مأرب': ['المدينة', 'مأرب', 'صرواح', 'حريب', 'الجوبة', 'مجزر'],
    'المهرة': ['الغيضة', 'حوف', 'شحن', 'قشن', 'سيحوت', 'المسيلة', 'حصوين', 'منعر', 'حات'],
    'البيضاء': ['البيضاء', 'رداع', 'مكيراس', 'السوادية', 'الزاهر'],
    'الضالع': ['الضالع', 'قعطبة', 'دمت', 'جبن', 'الحشاء', 'الشعيب'],
    'الجوف': ['الحزم', 'خب والشعف', 'المطمة', 'المصلوب', 'الغيل'],
    'حجة': ['حجة', 'عبس', 'المحابشة', 'كحلان عفار', 'حرض', 'ميدي'],
    'عمران': ['عمران', 'خمر', 'ريدة', 'ثلاء', 'شهارة', 'حوث'],
    'صعدة': ['صعدة', 'سحار', 'مجز', 'الصفراء', 'باقم', 'كتاف والبقع'],
    'ذمار': ['ذمار', 'جهران (معبر)', 'ضوران آنس', 'عتمة', 'وصاب العالي', 'وصاب السافل'],
    'المحويت': ['المحويت', 'شبام كوكبان', 'الطويلة', 'الرجم', 'الخبت'],
    'ريمة': ['الجبين', 'كسمة', 'مزهر', 'السلفية', 'بلاد الطعام'],
    'أرخبيل سقطرى': ['حديبو', 'قلنسية'],
    'صنعاء': ['همدان', 'بني مطر', 'سنحان وبني بهلول', 'الحيمتين', 'خولان', 'أرحب', 'نهم'],
  };
  
  // بيانات المتبرع
  static const String donorName = 'الاسم';
  static const String phoneNumber = 'رقم الهاتف';
  static const String bloodType = 'فصيلة الدم';
  static const String district = 'المحافظة';
  static const String age = 'العمر';
  static const String gender = 'الجنس';
  static const String male = 'ذكر';
  static const String female = 'أنثى';
  static const String notes = 'ملاحظات';
  static const String optional = 'اختياري';
  
  // أزرار
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String call = 'اتصال';
  static const String whatsapp = 'واتساب';
  static const String edit = 'تعديل';
  static const String delete = 'حذف';
  static const String confirm = 'تأكيد';
  static const String back = 'رجوع';
  static const String next = 'التالي';
  static const String submit = 'إرسال';
  
  // رسائل النجاح
  static const String donorAddedSuccessfully = 'تمت إضافة المتبرع بنجاح';
  static const String donorUpdatedSuccessfully = 'تم تحديث بيانات المتبرع';
  static const String donorDeletedSuccessfully = 'تم حذف المتبرع';
  
  // رسائل الخطأ
  static const String errorOccurred = 'حدث خطأ ما';
  static const String pleaseCheckInternet = 'يرجى التحقق من الاتصال بالإنترنت';
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String invalidPhone = 'رقم الهاتف غير صالح';
  static const String invalidAge = 'العمر غير صالح';
  
  // الإحصائيات
  static const String statistics = 'الإحصائيات';
  static const String totalDonors = 'إجمالي المتبرعين';
  static const String mostCommonBloodType = 'أكثر فصيلة متوفرة';
  static const String mostActiveDistrict = 'أكثر محافظة نشاطًا';
  static const String latestDonor = 'أحدث متبرع';
  
  // التوعية
  static const String awarenessTitle = 'التوعية والإرشادات';
  static const String importanceOfDonation = 'أهمية التبرع بالدم';
  static const String whoCanDonate = 'من يمكنه التبرع؟';
  static const String beforeDonation = 'قبل التبرع';
  static const String afterDonation = 'بعد التبرع';
  static const String prohibitedCases = 'الحالات الممنوعة';
  static const String donationInterval = 'المدة بين التبرعات';
  
  // الإبلاغ
  static const String reportTitle = 'الإبلاغ عن رقم غير صالح';
  static const String reportReason = 'سبب البلاغ';
  static const String numberNotWorking = 'الرقم لا يعمل';
  static const String wrongNumber = 'رقم خاطئ';
  static const String refusesToDonate = 'يرفض التبرع';
  static const String numberBusy = 'الرقم مشغول دائماً';
  static const String noAnswer = 'لا يرد على الاتصال';
  static const String deceased = 'متوفى';
  static const String movedAway = 'انتقل من المنطقة';
  static const String healthIssues = 'لديه مشاكل صحية';
  static const String other = 'سبب آخر';
  static const String reportSubmitted = 'تم إرسال البلاغ';
  
  // تسجيل الدخول
  static const String login = 'تسجيل الدخول';
  static const String email = 'البريد الإلكتروني';
  static const String password = 'كلمة المرور';
  static const String hospital = 'مستشفى';
  static const String admin = 'مدير النظام';
  
  // لوحة المستشفى
  static const String hospitalDashboard = 'لوحة إدارة المستشفى';
  static const String manageDonors = 'إدارة المتبرعين';
  static const String advancedSearch = 'بحث متقدم';
  static const String suspendedDonors = 'المتبرعين الموقوفين';
  static const String bloodTypeReport = 'تقرير الفصائل';
  static const String districtReport = 'تقرير المحافظات';
  static const String suspendFor6Months = 'إيقاف لمدة 6 أشهر';
  static const String updateLastDonation = 'تحديث آخر تبرع';
  
  // لوحة الأدمن
  static const String adminDashboard = 'لوحة إدارة النظام';
  static const String manageHospitals = 'إدارة المستشفيات';
  static const String reviewReports = 'مراجعة البلاغات';
  static const String systemOverview = 'نظرة عامة';
  static const String approveReport = 'قبول البلاغ';
  static const String rejectReport = 'رفض البلاغ';
  
  // رسالة WhatsApp الافتراضية
  static const String whatsappDefaultMessage = 
      'السلام عليكم ورحمة الله وبركاته\n'
      'نأمل منكم التبرع بالدم لإنقاذ حياة إنسان\n'
      'جزاكم الله خيراً';
}

