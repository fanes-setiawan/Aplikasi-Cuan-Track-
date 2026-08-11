// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ExcelHelper {
  static const List<String> headers = [
    'Tanggal (DD/MM/YYYY)',
    'Judul',
    'Jenis (Pemasukan/Pengeluaran)',
    'Kategori',
    'Metode Pembayaran',
    'Jumlah',
    'Catatan',
  ];

  static Future<void> generateTemplate() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    for (var i = 0; i < headers.length; i++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(bold: true);
    }

    var exampleRow = [
      '07/03/2026',
      'Contoh Transaksi',
      'Pengeluaran',
      'Makanan',
      'Tunai',
      '50000',
      'Beli nasi goreng',
    ];

    for (var i = 0; i < exampleRow.length; i++) {
      var cell = sheetObject.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1),
      );
      cell.value = TextCellValue(exampleRow[i]);
    }

    var fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/template_import_cuan_track.xlsx';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Template Import Cuan Track',
        text:
            'Gunakan file ini sebagai template untuk import transaksi ke Cuan Track.',
      );
    }
  }

  static Future<List<Map<String, dynamic>>> parseExcelFile(
    PlatformFile file,
  ) async {
    final bytes = File(file.path!).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    List<Map<String, dynamic>> data = [];

    for (var table in excel.tables.keys) {
      var rows = excel.tables[table]!.rows;
      if (rows.isEmpty) continue;

      for (var i = 1; i < rows.length; i++) {
        var row = rows[i];
        if (row.isEmpty || row[0] == null) continue;

        try {
          data.add({
            'date': _parseDate(row[0]?.value?.toString()),
            'title': row[1]?.value?.toString() ?? '',
            'type': _parseType(row[2]?.value?.toString()),
            'categoryName': row[3]?.value?.toString() ?? '',
            'paymentMethodName': row[4]?.value?.toString() ?? '',
            'amount': double.tryParse(row[5]?.value?.toString() ?? '0') ?? 0.0,
            'notes': row[6]?.value?.toString(),
          });
        } catch (e) {
          debugPrint('Error parsing row $i: $e');
        }
      }
    }
    return data;
  }

  static DateTime _parseDate(String? value) {
    if (value == null || value.isEmpty) return DateTime.now();
    try {
      if (value.contains('/')) {
        return DateFormat('dd/MM/yyyy').parse(value);
      } else if (value.contains('-')) {
        return DateFormat('yyyy-MM-dd').parse(value);
      }
    } catch (e) {
      debugPrint('Date parsing error: $e');
    }
    return DateTime.now();
  }

  static String _parseType(String? value) {
    if (value == null) return 'expense';
    final val = value.toLowerCase();
    if (val.contains('masuk')) return 'income';
    return 'expense';
  }
}
