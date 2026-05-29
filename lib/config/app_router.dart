import 'package:flutter/material.dart';

import '../models/donor_model.dart';
import '../models/report_model.dart';
import '../models/hospital_model.dart';
import '../utils/page_transitions.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/donor/add_donor_screen.dart';
import '../screens/donor/search_donors_screen.dart';

import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_donors_screen.dart';
import '../screens/admin/manage_hospitals_screen.dart';
import '../screens/admin/add_hospital_screen.dart';
import '../screens/admin/edit_hospital_screen.dart';
import '../screens/admin/edit_donor_screen.dart';
import '../screens/admin/report_detail_screen.dart';
import '../screens/admin/review_reports_screen.dart';
import '../screens/admin/system_overview_screen.dart';
import '../screens/admin/manage_locations_screen.dart';

import '../screens/hospital/hospital_dashboard_screen.dart';
import '../screens/hospital/manage_donors_hospital_screen.dart';
import '../screens/hospital/suspended_donors_screen.dart';
import '../screens/hospital/advanced_search_screen.dart';
import '../screens/hospital/reports_hub_screen.dart';
import '../screens/hospital/reports/comprehensive_report_screen.dart';
import '../screens/hospital/reports/district_report_screen.dart';
import '../screens/hospital/reports/blood_type_detailed_report_screen.dart';
import '../screens/hospital/reports/availability_report_screen.dart';
import '../screens/hospital/reports/monthly_summary_report_screen.dart';
import '../screens/hospital/blood_type_report_screen.dart';
import '../screens/hospital/export_reports_screen.dart';

import '../screens/info/about_screen.dart';
import '../screens/info/contact_screen.dart';
import '../screens/awareness/awareness_screen.dart';
import '../screens/reports/report_donor_screen.dart';
import '../main.dart'; // SplashScreen

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String login = '/login';

  static const String addDonor = '/donor/add';
  static const String searchDonors = '/donor/search';

  static const String adminDashboard = '/admin/dashboard';
  static const String adminManageDonors = '/admin/manage_donors';
  static const String adminManageHospitals = '/admin/manage_hospitals';
  static const String adminAddHospital = '/admin/add_hospital';
  static const String adminEditHospital = '/admin/edit_hospital';
  static const String adminEditDonor = '/admin/edit_donor';
  static const String adminReportDetail = '/admin/report_detail';
  static const String adminReviewReports = '/admin/review_reports';
  static const String adminSystemOverview = '/admin/system_overview';
  static const String adminManageLocations = '/admin/manage_locations';

  static const String hospitalDashboard = '/hospital/dashboard';
  static const String hospitalManageDonors = '/hospital/manage_donors';
  static const String hospitalSuspendedDonors = '/hospital/suspended_donors';
  static const String hospitalAdvancedSearch = '/hospital/advanced_search';
  static const String hospitalReportsHub = '/hospital/reports_hub';
  static const String hospitalReportComprehensive =
      '/hospital/report/comprehensive';
  static const String hospitalReportDistrict = '/hospital/report/district';
  static const String hospitalReportBloodTypeDetailed =
      '/hospital/report/blood_type_detailed';
  static const String hospitalReportAvailability =
      '/hospital/report/availability';
  static const String hospitalReportMonthlySummary =
      '/hospital/report/monthly_summary';
  static const String hospitalReportBloodType = '/hospital/report/blood_type';
  static const String hospitalExportReports = '/hospital/export_reports';

  static const String infoAbout = '/info/about';
  static const String infoContact = '/info/contact';
  static const String awareness = '/awareness';
  static const String reportDonor = '/report_donor';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Splash ───────────────────────────────────────────────────
      case splash:
        return AppPageTransitions.fade(
          const SplashScreen(),
          settings: settings,
        );
      case onboarding:
        return AppPageTransitions.fade(
          const OnboardingScreen(),
          settings: settings,
        );

      // ── الشاشات الجذرية → Fade ──────────────────────────────────
      case home:
        return AppPageTransitions.fade(const HomeScreen(), settings: settings);
      case login:
        return AppPageTransitions.fade(const LoginScreen(), settings: settings);

      // ── شاشات المتبرع ────────────────────────────────────────────
      case addDonor:
        return AppPageTransitions.slideUp(
          const AddDonorScreen(),
          settings: settings,
        );
      case searchDonors:
        return AppPageTransitions.slideFromRight(
          const SearchDonorsScreen(),
          settings: settings,
        );

      // ── الداشبوردات → Slide معتم (يتفادى ومضة كشف الشاشة الخلفية بعد الدخول) ──
      case adminDashboard:
        return AppPageTransitions.slideFromRight(
          const AdminDashboardScreen(),
          settings: settings,
        );
      case hospitalDashboard:
        return AppPageTransitions.slideFromRight(
          const HospitalDashboardScreen(),
          settings: settings,
        );

      // ── الشاشات الفرعية للأدمن → Slide ─────────────────────────
      case adminManageDonors:
        return AppPageTransitions.slideFromRight(
          const ManageDonorsScreen(),
          settings: settings,
        );
      case adminManageHospitals:
        return AppPageTransitions.slideFromRight(
          const ManageHospitalsScreen(),
          settings: settings,
        );
      case adminAddHospital:
        return AppPageTransitions.slideUp(
          const AddHospitalScreen(),
          settings: settings,
        );
      case adminEditHospital:
        if (settings.arguments is HospitalModel) {
          return AppPageTransitions.slideUp(
            EditHospitalScreen(hospital: settings.arguments as HospitalModel),
            settings: settings,
          );
        }
        return _errorRoute();
      case adminEditDonor:
        if (settings.arguments is DonorModel) {
          return AppPageTransitions.slideUp(
            EditDonorScreen(donor: settings.arguments as DonorModel),
            settings: settings,
          );
        }
        return _errorRoute();
      case adminReportDetail:
        if (settings.arguments is ReportModel) {
          return AppPageTransitions.slideFromRight(
            ReportDetailScreen(report: settings.arguments as ReportModel),
            settings: settings,
          );
        }
        return _errorRoute();
      case adminReviewReports:
        return AppPageTransitions.slideFromRight(
          const ReviewReportsScreen(),
          settings: settings,
        );
      case adminSystemOverview:
        return AppPageTransitions.slideFromRight(
          const SystemOverviewScreen(),
          settings: settings,
        );
      case adminManageLocations:
        return AppPageTransitions.slideFromRight(
          const ManageLocationsScreen(),
          settings: settings,
        );

      // ── الشاشات الفرعية للمستشفى → Slide ───────────────────────
      case hospitalManageDonors:
        return AppPageTransitions.slideFromRight(
          const ManageDonorsHospitalScreen(),
          settings: settings,
        );
      case hospitalSuspendedDonors:
        return AppPageTransitions.slideFromRight(
          const SuspendedDonorsScreen(),
          settings: settings,
        );
      case hospitalAdvancedSearch:
        return AppPageTransitions.slideFromRight(
          const AdvancedSearchScreen(),
          settings: settings,
        );
      case hospitalReportsHub:
        return AppPageTransitions.slideFromRight(
          const ReportsHubScreen(),
          settings: settings,
        );
      case hospitalReportComprehensive:
        return AppPageTransitions.slideFromRight(
          const ComprehensiveReportScreen(),
          settings: settings,
        );
      case hospitalReportDistrict:
        return AppPageTransitions.slideFromRight(
          const DistrictReportScreen(),
          settings: settings,
        );
      case hospitalReportBloodTypeDetailed:
        return AppPageTransitions.slideFromRight(
          const BloodTypeDetailedReportScreen(),
          settings: settings,
        );
      case hospitalReportAvailability:
        return AppPageTransitions.slideFromRight(
          const AvailabilityReportScreen(),
          settings: settings,
        );
      case hospitalReportMonthlySummary:
        return AppPageTransitions.slideFromRight(
          const MonthlySummaryReportScreen(),
          settings: settings,
        );
      case hospitalReportBloodType:
        return AppPageTransitions.slideFromRight(
          const BloodTypeReportScreen(),
          settings: settings,
        );
      case hospitalExportReports:
        return AppPageTransitions.slideFromRight(
          const ExportReportsScreen(),
          settings: settings,
        );

      // ── شاشات متنوعة ───────────────────────────────────────────
      case infoAbout:
        return AppPageTransitions.slideFromRight(
          const AboutScreen(),
          settings: settings,
        );
      case infoContact:
        return AppPageTransitions.slideFromRight(
          const ContactScreen(),
          settings: settings,
        );
      case awareness:
        return AppPageTransitions.slideFromRight(
          const AwarenessScreen(),
          settings: settings,
        );
      case reportDonor:
        return AppPageTransitions.slideUp(
          const ReportDonorScreen(),
          settings: settings,
        );

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return AppPageTransitions.fade(
      Scaffold(
        appBar: AppBar(title: const Text('خطأ في التنقل')),
        body: const Center(
          child: Text('عذراً، لم يتم العثور على الشاشة المطلوبة'),
        ),
      ),
    );
  }
}
