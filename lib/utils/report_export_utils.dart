import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart' as excel_pkg;

/// أدوات تصدير التقارير إلى PDF و Excel
class ReportExportUtils {
  /// تصدير بيانات إلى PDF
  static Future<bool> exportToPdf({
    required String title,
    required List<List<String>> headers,
    required List<List<String>> data,
    Map<String, String>? summary,
    String? createdBy,
  }) async {
    try {
      final pdf = pw.Document();

      // تحميل الخط العربي
      final fontData = await rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf');
      final fontDataBold = await rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf');
      final ttf = pw.Font.ttf(fontData);
      final ttfBold = pw.Font.ttf(fontDataBold);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: ttfBold,
          ),
          textDirection: pw.TextDirection.rtl,
          build: (pw.Context context) {
            return [
              // العنوان
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Center(
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              // الملخص (إذا وجد)
              if (summary != null && summary.isNotEmpty) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ملخص التقرير',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      ...summary.entries.map(
                        (entry) => pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 5),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(entry.key, style: const pw.TextStyle(fontSize: 14)),
                              pw.Text(
                                entry.value,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // الجدول
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                children: [
                  // الرؤوس
                  ...headers.map(
                    (headerRow) => pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue50,
                      ),
                      children: headerRow
                          .map(
                            (cell) => pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                cell,
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  // البيانات
                  ...data.map(
                    (row) => pw.TableRow(
                      children: row
                          .map(
                            (cell) => pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                cell,
                                style: const pw.TextStyle(fontSize: 11),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // تذييل
              pw.Divider(),
              pw.Text(
                'تم إنشاء التقرير بواسطة تطبيق بنك دم اليمن',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
                textAlign: pw.TextAlign.center,
              ),
              if (createdBy != null) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  'المستخدم: $createdBy',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Text(
                'التاريخ: ${DateTime.now().toString().split('.')[0]}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ];
          },
        ),
      );

      // حفظ ومشاركة الملف
      final timestamp = _getTimestamp();
      return await _saveAndShareFile(
        pdf.save(),
        '${_sanitizeFileName(title)}_$timestamp.pdf',
      );
    } catch (e) {
      print('خطأ في تصدير PDF: $e');
      return false;
    }
  }

  /// تصدير بيانات إلى Excel
  static Future<bool> exportToExcel({
    required String title,
    required String sheetName,
    required List<String> headers,
    required List<List<dynamic>> data,
    Map<String, String>? summary,
    String? createdBy,
  }) async {
    try {
      final excel = excel_pkg.Excel.createExcel();
      final sheet = excel[sheetName];

      int currentRow = 0;

      // إضافة العنوان
      sheet.merge(
        excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        excel_pkg.CellIndex.indexByColumnRow(
          columnIndex: headers.length - 1,
          rowIndex: currentRow,
        ),
      );
      var titleCell = sheet.cell(
        excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
      );
      titleCell.value = excel_pkg.TextCellValue(title);
      titleCell.cellStyle = excel_pkg.CellStyle(
        bold: true,
        fontSize: 16,
        horizontalAlign: excel_pkg.HorizontalAlign.Center,
        verticalAlign: excel_pkg.VerticalAlign.Center,
      );
      currentRow += 2;

      // إضافة الملخص (إذا وجد)
      if (summary != null && summary.isNotEmpty) {
        for (var entry in summary.entries) {
          sheet
              .cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
              .value = excel_pkg.TextCellValue(entry.key);
          sheet
              .cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
              .value = excel_pkg.TextCellValue(entry.value);
          currentRow++;
        }
        currentRow++;
      }

      // إضافة الرؤوس
      for (int i = 0; i < headers.length; i++) {
        var headerCell = sheet.cell(
          excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow),
        );
        headerCell.value = excel_pkg.TextCellValue(headers[i]);
        headerCell.cellStyle = excel_pkg.CellStyle(
          bold: true,
          backgroundColorHex: excel_pkg.ExcelColor.blue,
          fontColorHex: excel_pkg.ExcelColor.white,
          horizontalAlign: excel_pkg.HorizontalAlign.Center,
        );
      }
      currentRow++;

      // إضافة البيانات
      for (var row in data) {
        for (int i = 0; i < row.length; i++) {
          var cell = sheet.cell(
            excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow),
          );
          cell.value = excel_pkg.TextCellValue(row[i].toString());
          cell.cellStyle = excel_pkg.CellStyle(
            horizontalAlign: excel_pkg.HorizontalAlign.Center,
          );
        }
        currentRow++;
      }

      // إضافة تذييل
      currentRow += 2; // مسافة فارغة
      
      sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = excel_pkg.TextCellValue('تم إنشاء التقرير بواسطة تطبيق بنك دم اليمن');
      currentRow++;
      
      if (createdBy != null) {
        sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
            .value = excel_pkg.TextCellValue('المستخدم: $createdBy');
        currentRow++;
      }
      
      sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
          .value = excel_pkg.TextCellValue('التاريخ: ${DateTime.now().toString().split('.')[0]}');

      // حفظ ومشاركة الملف
      final bytes = excel.encode();
      if (bytes == null) return false;

      final timestamp = _getTimestamp();
      return await _saveAndShareFile(
        Future.value(Uint8List.fromList(bytes)),
        '${_sanitizeFileName(title)}_$timestamp.xlsx',
      );
    } catch (e) {
      print('خطأ في تصدير Excel: $e');
      return false;
    }
  }

  /// حفظ ومشاركة الملف
  static Future<bool> _saveAndShareFile(
    Future<Uint8List> bytes,
    String fileName,
  ) async {
    try {
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await bytes);

      // مشاركة الملف
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'تقرير من تطبيق بنك دم اليمن',
      );

      return true;
    } catch (e) {
      print('خطأ في حفظ/مشاركة الملف: $e');
      return false;
    }
  }

  /// تنظيف اسم الملف من الرموز غير المسموحة
  static String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[^\u0600-\u06FFa-zA-Z0-9_-]'), '_');
  }

  /// الحصول على timestamp بصيغة HHmm_DDMMYYYY
  static String _getTimestamp() {
    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}';
    final date = '${now.day.toString().padLeft(2, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.year}';
    return '${time}_$date';
  }
}

