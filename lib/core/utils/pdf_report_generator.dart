import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/home/domain/entities/transaction_entity.dart';
import '../../features/history/presentation/bloc/history_state.dart';

class PdfReportGenerator {
  static Future<void> generateAndDownloadReport(HistoryLoaded state) async {
    final pdf = pw.Document();

    final monthStr = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(state.currentMonth);
    final totalIncome = state.totalIncome;
    final totalExpense = state.totalExpense;
    final balance = totalIncome - totalExpense;

    final idrFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Grouping transactions by Date just like in HistoryScreen
    final Map<String, List<TransactionEntity>> grouped = {};
    for (var t in state.transactions) {
      final dateStr = DateFormat('dd MMM yyyy', 'id_ID').format(t.date);
      if (grouped.containsKey(dateStr)) {
        grouped[dateStr]!.add(t);
      } else {
        grouped[dateStr] = [t];
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Title
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Laporan Keuangan',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Cuan Track',
                    style: pw.TextStyle(
                      color: PdfColors.green700,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Periode: ${monthStr.toUpperCase()}',
              style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),

            // Summary Section
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RINGKASAN',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Pemasukan:'),
                      pw.Text(
                        idrFormat.format(totalIncome),
                        style: pw.TextStyle(color: PdfColors.green700),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Pengeluaran:'),
                      pw.Text(
                        idrFormat.format(totalExpense),
                        style: pw.TextStyle(color: PdfColors.red700),
                      ),
                    ],
                  ),
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Saldo Akhir:',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        idrFormat.format(balance),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Transactions Title
            pw.Text(
              'Rincian Transaksi',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),

            // Transactions List
            if (state.transactions.isEmpty)
              pw.Text(
                'Tidak ada transaksi di bulan ini.',
                style: const pw.TextStyle(color: PdfColors.grey),
              )
            else
              pw.Column(
                children: grouped.entries.map((entry) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        color: PdfColors.grey200,
                        child: pw.Text(
                          entry.key,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      ...entry.value.map((t) {
                        final isExpense = t.type == 'expense';
                        final amountSign = isExpense ? "-" : "+";
                        return pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      t.title.isNotEmpty
                                          ? t.title
                                          : t.categoryName ?? 'Transaksi',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Text(
                                      '${t.categoryName ?? ''} - ${t.notes ?? ''}',
                                      style: const pw.TextStyle(
                                        fontSize: 10,
                                        color: PdfColors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              pw.Text(
                                '$amountSign${idrFormat.format(t.amount)}',
                                style: pw.TextStyle(
                                  color: isExpense
                                      ? PdfColors.red700
                                      : PdfColors.green700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      pw.SizedBox(height: 15),
                    ],
                  );
                }).toList(),
              ),
          ];
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Laporan_Keuangan_CuanTrack_$monthStr.pdf'.replaceAll(' ', '_'),
    );
  }
}
