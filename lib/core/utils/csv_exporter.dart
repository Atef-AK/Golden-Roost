import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/flock.dart';
import '../../models/egg_record.dart';
import '../../models/feed.dart';
import '../../models/finance.dart';

class CsvExporter {
  static Future<String> exportFlocks(List<Flock> flocks) async {
    final rows = <List<dynamic>>[
      [
        'ID',
        'Name',
        'Species',
        'Breed',
        'Purpose',
        'Acquisition Date',
        'Initial Count',
        'Current Count',
        'Males',
        'Females',
        'Unit Price',
        'Total Cost',
        'Housing Location',
        'Supplier',
        'Status',
      ],
      ...flocks.map(
        (f) => [
          f.id,
          f.name,
          f.species,
          f.breed,
          f.purpose,
          f.acquisitionDate.toIso8601String(),
          f.startCount,
          f.currentCount,
          f.maleCount,
          f.femaleCount,
          f.purchasePricePerBird,
          f.totalPurchaseCost,
          f.housingLocation,
          f.supplier,
          f.isArchived ? 'Archived' : 'Active',
        ],
      ),
    ];

    final csvData = CsvEncoder().convert(rows);
    return await _saveAndShare(csvData, 'golden_roost_flocks.csv');
  }

  static Future<String> exportEggLogs(List<EggLog> logs) async {
    final rows = <List<dynamic>>[
      [
        'ID',
        'Flock ID',
        'Date',
        'Collection Time',
        'Total Eggs',
        'Usable Eggs',
        'Cracked Eggs',
        'Dirty Eggs',
        'Kept for Incubation',
        'Notes',
      ],
      ...logs.map(
        (l) => [
          l.id,
          l.flockId,
          l.date.toIso8601String(),
          l.collectionTime,
          l.totalEggs,
          l.usableEggs,
          l.crackedEggs,
          l.dirtyEggs,
          l.keptForIncubation,
          l.notes,
        ],
      ),
    ];

    final csvData = CsvEncoder().convert(rows);
    return await _saveAndShare(csvData, 'golden_roost_egg_logs.csv');
  }

  static Future<String> exportFinances(
    List<FinancialTransaction> finances,
  ) async {
    final rows = <List<dynamic>>[
      [
        'ID',
        'Type',
        'Category',
        'Amount',
        'Date',
        'Payment Status',
        'Amount Paid',
        'Is Capital Investment',
        'Flock ID',
        'Notes',
      ],
      ...finances.map(
        (f) => [
          f.id,
          f.type,
          f.category,
          f.amount,
          f.date.toIso8601String(),
          f.paymentStatus,
          f.amountPaid,
          f.isCapitalInvestment ? 'Yes' : 'No',
          f.flockId ?? '',
          f.notes,
        ],
      ),
    ];

    final csvData = CsvEncoder().convert(rows);
    return await _saveAndShare(csvData, 'golden_roost_finances.csv');
  }

  static Future<String> exportFeedTransactions(
    List<FeedTransaction> txs,
  ) async {
    final rows = <List<dynamic>>[
      [
        'ID',
        'Feed ID',
        'Flock ID',
        'Date',
        'Type',
        'Quantity (kg)',
        'Cost',
        'Notes',
      ],
      ...txs.map(
        (t) => [
          t.id,
          t.feedId,
          t.flockId ?? '',
          t.date.toIso8601String(),
          t.type,
          t.quantityKg,
          t.cost,
          t.notes,
        ],
      ),
    ];

    final csvData = CsvEncoder().convert(rows);
    return await _saveAndShare(csvData, 'golden_roost_feed_transactions.csv');
  }

  static Future<String> _saveAndShare(String csvData, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csvData);

    try {
      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Exported from Golden Roost');
    } catch (_) {
      // If share plugin is unavailable on desktop, return the saved file path
    }
    return file.path;
  }
}
