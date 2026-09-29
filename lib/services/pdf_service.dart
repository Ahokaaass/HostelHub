import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfMessBillData {
  final String studentName;
  final String month;
  final num breakfastCount;
  final num lunchCount;
  final num dinnerCount;
  final num totalAmount;

  const PdfMessBillData({
    required this.studentName,
    required this.month,
    required this.breakfastCount,
    required this.lunchCount,
    required this.dinnerCount,
    required this.totalAmount,
  });
}

class PdfPurchaseItem {
  final String itemName;
  final num quantity;
  final String unit;
  final num price;
  final num total;

  const PdfPurchaseItem({
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.total,
  });
}

class PdfPurchaseData {
  final DateTime date;
  final List<PdfPurchaseItem> items;

  const PdfPurchaseData({required this.date, required this.items});
}

class PdfOrderItem {
  final String itemName;
  final num quantity;
  final String? brand;

  const PdfOrderItem({
    required this.itemName,
    required this.quantity,
    this.brand,
  });
}

class PdfOrderData {
  final DateTime? date;
  final List<PdfOrderItem> items;

  const PdfOrderData({required this.date, required this.items});
}

class PdfService {
  const PdfService();

  Future<Uint8List> generateMessBillPdf(PdfMessBillData data) async {
    final doc = pw.Document();
    final generatedAt = DateTime.now();

    doc.addPage(
      pw.MultiPage(
        pageTheme: _theme(),
        footer: (context) => _footer(generatedAt),
        build: (context) => [
          _title('Mess Bill Report'),
          pw.SizedBox(height: 16),
          _sectionTitle('Student Info'),
          _infoTable([
            ['Student Name', data.studentName],
            ['Month', data.month],
          ]),
          pw.SizedBox(height: 16),
          _sectionTitle('Attendance Summary'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _headerRow(['Meal Type', 'Count']),
              _tableRow(['Breakfast', _fmtNum(data.breakfastCount)]),
              _tableRow(['Lunch', _fmtNum(data.lunchCount)]),
              _tableRow(['Dinner', _fmtNum(data.dinnerCount)]),
            ],
          ),
          pw.SizedBox(height: 18),
          _totalBox(
            label: 'Total Amount',
            value: 'INR ${_money(data.totalAmount)}',
          ),
        ],
      ),
    );

    return doc.save();
  }

  Future<Uint8List> generatePurchasePdf(PdfPurchaseData data) async {
    final doc = pw.Document();
    final generatedAt = DateTime.now();
    final totalExpenditure = data.items.fold<num>(
      0,
      (sum, item) => sum + item.total,
    );

    doc.addPage(
      pw.MultiPage(
        pageTheme: _theme(),
        footer: (context) => _footer(generatedAt),
        build: (context) => [
          _title('Purchased Items Report'),
          pw.SizedBox(height: 12),
          pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(data.date)}'),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.4),
              1: pw.FlexColumnWidth(1.2),
              2: pw.FlexColumnWidth(1.2),
              3: pw.FlexColumnWidth(1.2),
              4: pw.FlexColumnWidth(1.4),
            },
            children: [
              _headerRow(['Item Name', 'Quantity', 'Unit', 'Price', 'Total']),
              ...data.items.map(
                (item) => _tableRow([
                  item.itemName,
                  _fmtNum(item.quantity),
                  item.unit,
                  _money(item.price),
                  _money(item.total),
                ]),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          _totalBox(
            label: 'Total Expenditure',
            value: 'INR ${_money(totalExpenditure)}',
          ),
        ],
      ),
    );

    return doc.save();
  }

  Future<Uint8List> generateOrderPdf(PdfOrderData data) async {
    final doc = pw.Document();
    final generatedAt = DateTime.now();

    doc.addPage(
      pw.MultiPage(
        pageTheme: _theme(),
        footer: (context) => _footer(generatedAt),
        build: (context) => [
          _title('Ordered Items Report'),
          if (data.date != null) ...[
            pw.SizedBox(height: 10),
            pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(data.date!)}'),
          ],
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.5),
              1: pw.FlexColumnWidth(1.2),
              2: pw.FlexColumnWidth(1.7),
            },
            children: [
              _headerRow(['Item Name', 'Quantity', 'Brand']),
              ...data.items.map(
                (item) => _tableRow([
                  item.itemName,
                  _fmtNum(item.quantity),
                  (item.brand == null || item.brand!.trim().isEmpty)
                      ? '-'
                      : item.brand!.trim(),
                ]),
              ),
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }

  pw.PageTheme _theme() {
    return pw.PageTheme(
      margin: const pw.EdgeInsets.all(28),
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
    );
  }

  pw.Widget _title(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
    );
  }

  pw.Widget _sectionTitle(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
    );
  }

  pw.Widget _infoTable(List<List<String>> rows) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.4),
        1: pw.FlexColumnWidth(2.8),
      },
      children: rows.map((row) => _tableRow(row)).toList(),
    );
  }

  pw.TableRow _headerRow(List<String> cells) {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.blue50),
      children: cells
          .map(
            (cell) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              child: pw.Text(
                cell,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          )
          .toList(),
    );
  }

  pw.TableRow _tableRow(List<String> cells) {
    return pw.TableRow(
      children: cells
          .map(
            (cell) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              child: pw.Text(cell),
            ),
          )
          .toList(),
    );
  }

  pw.Widget _totalBox({required String label, required String value}) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _footer(DateTime generatedAt) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Generated: ${DateFormat('dd/MM/yyyy hh:mm a').format(generatedAt)}',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ),
    );
  }

  String _money(num value) => value.toStringAsFixed(2);

  String _fmtNum(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}
