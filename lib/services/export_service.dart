import 'dart:io';
import 'package:flutter/services.dart';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import '../models/donor_model.dart';
import '../models/dashboard_statistics_model.dart';
import '../utils/error_handler.dart';
import '../utils/helpers.dart';

/// خدمة تصدير التقارير إلى Excel و PDF
class ExportService {
  // الخط العربي للـ PDF
  static pw.Font? _arabicFont;

  /// تحميل الخط العربي
  static Future<pw.Font> _loadArabicFont() async {
    if (_arabicFont != null) return _arabicFont!;

    try {
      final fontData = await rootBundle.load(
        'assets/fonts/IBMPlexSansArabic-Regular.ttf',
      );
      _arabicFont = pw.Font.ttf(fontData);
      return _arabicFont!;
    } catch (e) {
      throw Exception('فشل تحميل الخط العربي: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// تصدير قائمة المتبرعين إلى Excel
  Future<String> exportDonorsToExcel(List<DonorModel> donors) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheet = excel['المتبرعين'];

      // إضافة العناوين
      sheet.appendRow([
        TextCellValue('الرقم'),
        TextCellValue('الاسم'),
        TextCellValue('رقم الهاتف'),
        TextCellValue('فصيلة الدم'),
        TextCellValue('المديرية'),
        TextCellValue('العمر'),
        TextCellValue('الجنس'),
        TextCellValue('الحالة'),
        TextCellValue('تاريخ الإضافة'),
      ]);

      // تنسيق العناوين
      for (var i = 0; i < 9; i++) {
        var cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
      }

      // إضافة البيانات
      int rowIndex = 1;
      for (var donor in donors) {
        sheet.appendRow([
          IntCellValue(rowIndex),
          TextCellValue(donor.name),
          TextCellValue(Helpers.displayPhoneNumber(donor.phoneNumber)),
          TextCellValue(donor.bloodType),
          TextCellValue(donor.district),
          IntCellValue(donor.age),
          TextCellValue(donor.gender),
          TextCellValue(donor.isAvailable ? 'متاح' : 'موقوف'),
          TextCellValue(DateFormat('yyyy-MM-dd').format(donor.createdAt)),
        ]);
        rowIndex++;
      }

      // حفظ الملف
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/donors_report_$timestamp.xlsx';

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      return filePath;
    } catch (e) {
      throw Exception('فشل تصدير Excel: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// تصدير الإحصائيات إلى Excel
  Future<String> exportStatisticsToExcel(DashboardStatisticsModel stats) async {
    try {
      var excel = Excel.createExcel();

      // ورقة الإحصائيات العامة
      Sheet statsSheet = excel['الإحصائيات العامة'];
      statsSheet.appendRow([TextCellValue('المؤشر'), TextCellValue('القيمة')]);

      // تنسيق العناوين
      for (var i = 0; i < 2; i++) {
        var cell = statsSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#2196F3'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
      }

      // البيانات
      statsSheet.appendRow([
        TextCellValue('إجمالي المتبرعين'),
        IntCellValue(stats.totalDonors),
      ]);
      statsSheet.appendRow([
        TextCellValue('المتاحين للتبرع'),
        IntCellValue(stats.availableDonors),
      ]);
      statsSheet.appendRow([
        TextCellValue('الموقوفين'),
        IntCellValue(stats.suspendedDonors),
      ]);
      statsSheet.appendRow([
        TextCellValue('جدد هذا الشهر'),
        IntCellValue(stats.newDonorsThisMonth),
      ]);
      statsSheet.appendRow([
        TextCellValue('المناطق المغطاة'),
        IntCellValue(stats.coveredDistrictsCount),
      ]);
      if (stats.mostCommonBloodType != null) {
        statsSheet.appendRow([
          TextCellValue('أكثر فصيلة'),
          TextCellValue(
            '${stats.mostCommonBloodType} (${stats.mostCommonBloodTypeCount})',
          ),
        ]);
      }

      // ورقة توزيع فصائل الدم
      Sheet bloodSheet = excel['فصائل الدم'];
      bloodSheet.appendRow([TextCellValue('الفصيلة'), TextCellValue('العدد')]);

      for (var i = 0; i < 2; i++) {
        var cell = bloodSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#F44336'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
      }

      stats.bloodTypeDistribution.forEach((bloodType, count) {
        bloodSheet.appendRow([TextCellValue(bloodType), IntCellValue(count)]);
      });

      // ورقة توزيع المديريات
      Sheet districtSheet = excel['المديريات'];
      districtSheet.appendRow([
        TextCellValue('المديرية'),
        TextCellValue('العدد'),
      ]);

      for (var i = 0; i < 2; i++) {
        var cell = districtSheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#FF9800'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
      }

      stats.districtDistribution.forEach((district, count) {
        districtSheet.appendRow([TextCellValue(district), IntCellValue(count)]);
      });

      // حذف الورقة الافتراضية
      excel.delete('Sheet1');

      // حفظ الملف
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/statistics_report_$timestamp.xlsx';

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      return filePath;
    } catch (e) {
      throw Exception('فشل تصدير الإحصائيات: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// تصدير قائمة المتبرعين إلى PDF
  Future<String> exportDonorsToPDF(List<DonorModel> donors) async {
    try {
      // تحميل الخط العربي أولاً
      final arabicFont = await _loadArabicFont();

      final pdf = pw.Document();

      // تقسيم المتبرعين إلى صفحات (25 متبرع لكل صفحة)
      const donorsPerPage = 25;
      final totalPages = (donors.length / donorsPerPage).ceil();

      for (var pageIndex = 0; pageIndex < totalPages; pageIndex++) {
        final startIndex = pageIndex * donorsPerPage;
        final endIndex = (startIndex + donorsPerPage > donors.length)
            ? donors.length
            : startIndex + donorsPerPage;
        final pageDonors = donors.sublist(startIndex, endIndex);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            textDirection: pw.TextDirection.rtl,
            theme: pw.ThemeData.withFont(base: arabicFont),
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // العنوان
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    color: PdfColors.green,
                    child: pw.Text(
                      'تقرير المتبرعين - بنك دم اليمن',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        font: arabicFont,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  // معلومات التقرير
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                        style: pw.TextStyle(fontSize: 10, font: arabicFont),
                      ),
                      pw.Text(
                        'صفحة ${pageIndex + 1} من $totalPages',
                        style: pw.TextStyle(fontSize: 10, font: arabicFont),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 15),

                  // الجدول
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    children: [
                      // العناوين
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _buildTableCell(
                            'م',
                            isHeader: true,
                            font: arabicFont,
                          ),
                          _buildTableCell(
                            'الاسم',
                            isHeader: true,
                            font: arabicFont,
                          ),
                          _buildTableCell(
                            'الهاتف',
                            isHeader: true,
                            font: arabicFont,
                          ),
                          _buildTableCell(
                            'الفصيلة',
                            isHeader: true,
                            font: arabicFont,
                          ),
                          _buildTableCell(
                            'المديرية',
                            isHeader: true,
                            font: arabicFont,
                          ),
                          _buildTableCell(
                            'الحالة',
                            isHeader: true,
                            font: arabicFont,
                          ),
                        ],
                      ),

                      // البيانات
                      ...pageDonors.asMap().entries.map((entry) {
                        final index = startIndex + entry.key + 1;
                        final donor = entry.value;
                        return pw.TableRow(
                          children: [
                            _buildTableCell(index.toString(), font: arabicFont),
                            _buildTableCell(donor.name, font: arabicFont),
                            _buildTableCell(
                              Helpers.displayPhoneNumber(donor.phoneNumber),
                              font: arabicFont,
                            ),
                            _buildTableCell(donor.bloodType, font: arabicFont),
                            _buildTableCell(donor.district, font: arabicFont),
                            _buildTableCell(
                              donor.isAvailable ? 'متاح' : 'موقوف',
                              font: arabicFont,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }

      // حفظ الملف
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/donors_report_$timestamp.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      throw Exception('فشل تصدير PDF: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// تصدير الإحصائيات إلى PDF
  Future<String> exportStatisticsToPDF(DashboardStatisticsModel stats) async {
    try {
      // تحميل الخط العربي أولاً
      final arabicFont = await _loadArabicFont();

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: arabicFont),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // العنوان الرئيسي
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  color: PdfColors.blue,
                  child: pw.Text(
                    'تقرير الإحصائيات - بنك دم اليمن',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      font: arabicFont,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),

                // التاريخ
                pw.Text(
                  'التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 11, font: arabicFont),
                ),
                pw.SizedBox(height: 20),

                // الإحصائيات العامة
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  color: PdfColors.grey200,
                  child: pw.Text(
                    'الإحصائيات العامة',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      font: arabicFont,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),

                _buildStatRow(
                  'إجمالي المتبرعين',
                  stats.totalDonors.toString(),
                  arabicFont,
                ),
                _buildStatRow(
                  'المتاحين للتبرع الآن',
                  stats.availableDonors.toString(),
                  arabicFont,
                ),
                _buildStatRow(
                  'الموقوفين حالياً',
                  stats.suspendedDonors.toString(),
                  arabicFont,
                ),
                _buildStatRow(
                  'جدد هذا الشهر',
                  stats.newDonorsThisMonth.toString(),
                  arabicFont,
                ),
                _buildStatRow(
                  'المناطق المغطاة',
                  stats.coveredDistrictsCount.toString(),
                  arabicFont,
                ),
                if (stats.mostCommonBloodType != null)
                  _buildStatRow(
                    'أكثر فصيلة',
                    '${stats.mostCommonBloodType} (${stats.mostCommonBloodTypeCount})',
                    arabicFont,
                  ),

                pw.SizedBox(height: 20),

                // فصائل الدم
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  color: PdfColors.red100,
                  child: pw.Text(
                    'توزيع فصائل الدم',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      font: arabicFont,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        _buildTableCell(
                          'الفصيلة',
                          isHeader: true,
                          font: arabicFont,
                        ),
                        _buildTableCell(
                          'العدد',
                          isHeader: true,
                          font: arabicFont,
                        ),
                      ],
                    ),
                    ...stats.bloodTypeDistribution.entries.map((entry) {
                      return pw.TableRow(
                        children: [
                          _buildTableCell(entry.key, font: arabicFont),
                          _buildTableCell(
                            entry.value.toString(),
                            font: arabicFont,
                          ),
                        ],
                      );
                    }),
                  ],
                ),

                pw.SizedBox(height: 20),

                // المديريات
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  color: PdfColors.orange100,
                  child: pw.Text(
                    'توزيع المديريات',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      font: arabicFont,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),

                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        _buildTableCell(
                          'المديرية',
                          isHeader: true,
                          font: arabicFont,
                        ),
                        _buildTableCell(
                          'العدد',
                          isHeader: true,
                          font: arabicFont,
                        ),
                      ],
                    ),
                    ...stats.districtDistribution.entries.map((entry) {
                      return pw.TableRow(
                        children: [
                          _buildTableCell(entry.key, font: arabicFont),
                          _buildTableCell(
                            entry.value.toString(),
                            font: arabicFont,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // حفظ الملف
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/statistics_report_$timestamp.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      throw Exception('فشل تصدير الإحصائيات PDF: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// فتح ملف
  Future<void> openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        throw Exception('فشل فتح الملف: ${result.message}');
      }
    } catch (e) {
      throw Exception('فشل فتح الملف: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// مشاركة ملف
  Future<void> shareFile(String filePath, String subject) async {
    try {
      await Share.shareXFiles([XFile(filePath)], subject: subject);
    } catch (e) {
      throw Exception('فشل مشاركة الملف: ${ErrorHandler.getArabicMessage(e)}');
    }
  }

  /// بناء خلية جدول PDF
  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.Font? font,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          font: font,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  /// بناء صف إحصائية
  pw.Widget _buildStatRow(String label, String value, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 12, font: font)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
              font: font,
            ),
          ),
        ],
      ),
    );
  }
}
