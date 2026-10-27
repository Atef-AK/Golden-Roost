import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/farm_settings.dart';
import '../../models/flock.dart';
import '../../models/feed.dart';
import '../../models/finance.dart';
import 'formatters.dart';

class PdfReportGenerator {
  static Future<Uint8List> generateFarmReport({
    required FarmSettings settings,
    required List<Flock> flocks,
    required List<FeedItem> feedItems,
    required List<FinancialTransaction> finances,
    required int totalLiveBirds,
    required int eggsCollectedToday,
    required double totalIncome,
    required double totalExpenses,
    required double netProfit,
  }) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#1B4332');
    final accentColor = PdfColor.fromHex('#D97706');
    final sageColor = PdfColor.fromHex('#D8F3DC');
    final grayColor = PdfColor.fromHex('#4B5563');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      settings.farmName,
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.Text(
                      'Golden Roost — Executive Poultry Farm Report',
                      style: pw.TextStyle(fontSize: 12, color: grayColor),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Date: ${AppFormatters.formatShortDate(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Currency: ${settings.currency}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(color: primaryColor, thickness: 1.5),
            pw.SizedBox(height: 14),

            // Key KPI Summary Cards
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: sageColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildKpiPdf(
                    'Total Live Birds',
                    totalLiveBirds.toString(),
                    primaryColor,
                  ),
                  _buildKpiPdf(
                    'Eggs Today',
                    eggsCollectedToday.toString(),
                    accentColor,
                  ),
                  _buildKpiPdf(
                    'Total Revenue',
                    AppFormatters.formatCurrency(
                      totalIncome,
                      settings.currency,
                    ),
                    primaryColor,
                  ),
                  _buildKpiPdf(
                    'Net Profit',
                    AppFormatters.formatCurrency(netProfit, settings.currency),
                    primaryColor,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Active Flocks Section
            pw.Text(
              'Flocks & Inventory Overview',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: [
                'Flock Name',
                'Species / Breed',
                'Age',
                'Live Count',
                'M/F',
                'Location',
              ],
              data: flocks
                  .map(
                    (f) => [
                      f.name,
                      '${f.species.toUpperCase()} (${f.breed})',
                      '${f.ageInDays}d (${f.ageInWeeks}w)',
                      f.currentCount.toString(),
                      '${f.maleCount}M / ${f.femaleCount}F',
                      f.housingLocation.isNotEmpty ? f.housingLocation : 'N/A',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(color: primaryColor),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
            ),
            pw.SizedBox(height: 20),

            // Feed Stock Section
            pw.Text(
              'Feed Stock & Inventory',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: [
                'Feed Type',
                'Current Stock (kg)',
                'Status',
                'Bag Size',
                'Price/Bag',
              ],
              data: feedItems
                  .map(
                    (fi) => [
                      fi.name,
                      fi.currentStockKg.toStringAsFixed(1),
                      fi.isLowStock ? 'LOW STOCK ALERT' : 'Normal',
                      '${fi.bagWeightKg} kg',
                      AppFormatters.formatCurrency(
                        fi.costPerBag,
                        settings.currency,
                      ),
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(color: accentColor),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
            ),
            pw.SizedBox(height: 20),

            // Financial Summary Section
            pw.Text(
              'Financial Statement (Income & Expense)',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Operating Income:'),
                pw.Text(
                  AppFormatters.formatCurrency(totalIncome, settings.currency),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Operating Expenses:'),
                pw.Text(
                  AppFormatters.formatCurrency(
                    totalExpenses,
                    settings.currency,
                  ),
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Net Operating Result:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.Text(
                  AppFormatters.formatCurrency(netProfit, settings.currency),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: netProfit >= 0 ? primaryColor : PdfColors.red,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // Footer note
            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Text(
                'Generated automatically by Golden Roost Poultry Manager. Keep accurate daily logs for reliable insights.',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: grayColor,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildKpiPdf(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static Future<void> printOrShareReport(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'GoldenRoost_Farm_Report.pdf',
    );
  }
}
