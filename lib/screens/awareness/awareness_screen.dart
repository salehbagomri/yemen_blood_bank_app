import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';

/// صفحة التوعية والإرشادات
class AwarenessScreen extends StatelessWidget {
  const AwarenessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.awarenessTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // مقدمة
          _IntroSection(),
          
          const SizedBox(height: 20),
          
          // أهمية التبرع
          _SectionCard(
            icon: Icons.favorite,
            iconColor: AppColors.primary,
            title: AppStrings.importanceOfDonation,
            content: _importanceContent,
          ),
          
          const SizedBox(height: 16),
          
          // من يمكنه التبرع
          _SectionCard(
            icon: Icons.check_circle,
            iconColor: AppColors.success,
            title: AppStrings.whoCanDonate,
            content: _whoCanDonateContent,
          ),
          
          const SizedBox(height: 16),
          
          // قبل التبرع
          _SectionCard(
            icon: Icons.info,
            iconColor: AppColors.info,
            title: AppStrings.beforeDonation,
            content: _beforeDonationContent,
          ),
          
          const SizedBox(height: 16),
          
          // بعد التبرع
          _SectionCard(
            icon: Icons.lightbulb,
            iconColor: AppColors.warning,
            title: AppStrings.afterDonation,
            content: _afterDonationContent,
          ),
          
          const SizedBox(height: 16),
          
          // الحالات الممنوعة
          _SectionCard(
            icon: Icons.block,
            iconColor: AppColors.error,
            title: AppStrings.prohibitedCases,
            content: _prohibitedCasesContent,
          ),
          
          const SizedBox(height: 16),
          
          // المدة بين التبرعات
          _SectionCard(
            icon: Icons.schedule,
            iconColor: AppColors.primary,
            title: AppStrings.donationInterval,
            content: _donationIntervalContent,
          ),
          
          const SizedBox(height: 16),
          
          // فصائل الدم
          _BloodTypesSection(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// قسم المقدمة
class _IntroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bloodtype_rounded,
            size: 60,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'التبرع بالدم ينقذ الأرواح',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'كل قطرة دم تتبرع بها يمكن أن تنقذ حياة 3 أشخاص',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// بطاقة قسم
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> content;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // المحتوى
            ...content.map((text) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

/// قسم فصائل الدم
class _BloodTypesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bloodtype,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'فصائل الدم',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // جدول الفصائل
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _BloodTypeChip('A+', AppColors.bloodTypeA),
                _BloodTypeChip('A-', AppColors.bloodTypeA),
                _BloodTypeChip('B+', AppColors.bloodTypeB),
                _BloodTypeChip('B-', AppColors.bloodTypeB),
                _BloodTypeChip('AB+', AppColors.bloodTypeAB),
                _BloodTypeChip('AB-', AppColors.bloodTypeAB),
                _BloodTypeChip('O+', AppColors.bloodTypeO),
                _BloodTypeChip('O-', AppColors.bloodTypeO),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'O- هي الفصيلة العامة التي يمكن أن تُعطى لجميع الفصائل',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// شريحة فصيلة الدم
class _BloodTypeChip extends StatelessWidget {
  final String bloodType;
  final Color color;

  const _BloodTypeChip(this.bloodType, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          bloodType,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

// المحتويات
final List<String> _importanceContent = [
  'التبرع بالدم يساعد في إنقاذ حياة المرضى والمصابين',
  'كل وحدة دم يمكن أن تنقذ حياة ثلاثة أشخاص',
  'التبرع آمن تماماً ولا يضر بصحة المتبرع',
  'عملية التبرع تستغرق 10-15 دقيقة فقط',
  'التبرع المنتظم له فوائد صحية للمتبرع نفسه',
];

final List<String> _whoCanDonateContent = [
  'أن يكون العمر بين 18 و 65 سنة',
  'أن يكون الوزن أكثر من 50 كيلوجرام',
  'أن يكون بصحة جيدة وخالي من الأمراض',
  'أن لا يكون مصاباً بأي عدوى',
  'أن يكون مستوى الهيموجلوبين طبيعياً',
];

final List<String> _beforeDonationContent = [
  'احصل على قسط كافٍ من النوم ليلة التبرع',
  'تناول وجبة صحية قبل التبرع بساعتين',
  'اشرب كمية كافية من الماء والسوائل',
  'تجنب الأطعمة الدسمة قبل التبرع',
  'أخبر الطبيب عن أي أدوية تتناولها',
];

final List<String> _afterDonationContent = [
  'استرح لمدة 10-15 دقيقة بعد التبرع',
  'اشرب كمية كبيرة من السوائل',
  'تناول وجبة خفيفة',
  'تجنب المجهود البدني الشاق لمدة 24 ساعة',
  'إذا شعرت بدوار، اجلس فوراً وارفع قدميك',
];

final List<String> _prohibitedCasesContent = [
  'مرضى القلب والكبد والكلى',
  'مرضى السكري غير المنضبط',
  'الحوامل والمرضعات',
  'من لديه عدوى نشطة أو حمى',
  'من تناول المضادات الحيوية مؤخراً',
  'من أجرى عملية جراحية حديثاً',
];

final List<String> _donationIntervalContent = [
  'يجب أن تمر 6 أشهر (180 يوم) على الأقل بين كل تبرع وآخر',
  'هذه المدة ضرورية لتعويض الجسم للدم المفقود',
  'يمكن للرجال التبرع كل 3 أشهر في بعض الحالات',
  'يجب على النساء الانتظار 4 أشهر على الأقل',
  'الالتزام بهذه المدة يحافظ على صحة المتبرع',
];

