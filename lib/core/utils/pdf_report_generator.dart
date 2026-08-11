import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/home/domain/entities/transaction_entity.dart';
import '../../features/history/presentation/bloc/history_state.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfReportGenerator {
  static Future<pw.ThemeData> _getTheme() async {
    pw.Font? emojiFont;
    pw.Font? symbolFont;
    try {
      emojiFont = await PdfGoogleFonts.notoColorEmoji();
      symbolFont = await PdfGoogleFonts.notoSansJPRegular();
    } catch (e) {
      debugPrint('Failed to load fallback fonts: $e');
    }

    return pw.ThemeData.withFont(
      fontFallback: [
        if (emojiFont != null) emojiFont,
        if (symbolFont != null) symbolFont,
      ],
    );
  }

  static Future<void> generateAndDownloadReport(HistoryLoaded state) async {
    final pdf = pw.Document();
    final theme = await _getTheme();

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
        margin: pw.EdgeInsets.all(AppSizes.padding32),
        theme: theme,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Laporan Keuangan',
                    style: pw.TextStyle(
                      fontSize: AppSizes.font24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Cuan Track',
                    style: pw.TextStyle(
                      color: PdfColors.green700,
                      fontSize: AppSizes.font20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Periode: ${monthStr.toUpperCase()}',
              style: pw.TextStyle(
                fontSize: AppSizes.font14,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: AppSizes.paddingV20),

            pw.Container(
              padding: pw.EdgeInsets.all(AppSizes.padding16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.all(
                  pw.Radius.circular(AppSizes.radius8),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RINGKASAN',
                    style: pw.TextStyle(
                      fontSize: AppSizes.font12,
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
                          fontSize: AppSizes.font16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            pw.Text(
              'Rincian Transaksi',
              style: pw.TextStyle(
                fontSize: AppSizes.font18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),

            if (state.transactions.isEmpty)
              pw.Text(
                'Tidak ada transaksi di bulan ini.',
                style: const pw.TextStyle(color: PdfColors.grey),
              )
            else
              ...grouped.entries.expand((entry) {
                return [
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.symmetric(
                      vertical: AppSizes.paddingV4,
                      horizontal: AppSizes.padding8,
                    ),
                    color: PdfColors.grey200,
                    child: pw.Text(
                      entry.key,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: AppSizes.font12,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  ...entry.value.map((t) {
                    final isExpense = t.type == 'expense';
                    final amountSign = isExpense ? "-" : "+";
                    return pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        vertical: AppSizes.paddingV4,
                        horizontal: AppSizes.padding8,
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
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
                                  style: pw.TextStyle(
                                    fontSize: AppSizes.font10,
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
                  }),
                  pw.SizedBox(height: 15),
                ];
              }),
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

  static Future<Uint8List> generateAllTimeReportBytes(
    String userName,
    List<TransactionEntity> transactions,
    double totalIncome,
    double totalExpense,
  ) async {
    final pdf = pw.Document();
    final theme = await _getTheme();
    final balance = totalIncome - totalExpense;
    final printDate = DateFormat(
      'dd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(DateTime.now());

    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/logo/logo_app.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      debugPrint('Failed to load logo watermark: $e');
    }

    final idrFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final Map<String, List<TransactionEntity>> grouped = {};
    for (var t in transactions) {
      final dateStr = DateFormat('dd MMM yyyy', 'id_ID').format(t.date);
      if (grouped.containsKey(dateStr)) {
        grouped[dateStr]!.add(t);
      } else {
        grouped[dateStr] = [t];
      }
    }

    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      theme: theme,
      buildBackground: (pw.Context context) {
        return pw.Center(
          child: pw.Opacity(
            opacity: 0.12,
            child: logoImage != null
                ? pw.Image(logoImage, width: 220, height: 220)
                : pw.Transform.rotate(
                    angle: 0.45,
                    child: pw.Text(
                      'CUAN TRACK\nPROFESSIONAL REPORT',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 48,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
          ),
        );
      },
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN KEUANGAN KESELURUHAN',
                      style: pw.TextStyle(
                        fontSize: AppSizes.font16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blueGrey800,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'All-Time Lifetime Financial Statement',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Cuan Track',
                      style: pw.TextStyle(
                        color: PdfColors.green700,
                        fontSize: AppSizes.font20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Aplikasi Pencatat Keuangan',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: AppSizes.paddingV8),
            pw.Divider(thickness: 1.5, color: PdfColors.blueGrey100),
            pw.SizedBox(height: AppSizes.paddingV12),

            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'DOKUMEN INFORMASI',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey400,
                        ),
                      ),
                      pw.SizedBox(height: AppSizes.paddingV4),
                      pw.Row(
                        children: [
                          pw.Text(
                            'Pemilik Akun: ',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            userName,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        children: [
                          pw.Text(
                            'Periode Laporan: ',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Semua Waktu (All-Time)',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'METADATA SISTEM',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey400,
                        ),
                      ),
                      pw.SizedBox(height: AppSizes.paddingV4),
                      pw.Row(
                        children: [
                          pw.Text(
                            'Tanggal Cetak: ',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            printDate,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        children: [
                          pw.Text(
                            'Total Transaksi: ',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '${transactions.length} kali',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'STATUS FINANSIAL',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey400,
                        ),
                      ),
                      pw.SizedBox(height: AppSizes.paddingV4),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(
                          vertical: AppSizes.paddingV4,
                          horizontal: AppSizes.padding8,
                        ),
                        decoration: pw.BoxDecoration(
                          color: balance >= 0
                              ? PdfColors.green50
                              : PdfColors.red50,
                          borderRadius: pw.BorderRadius.all(
                            pw.Radius.circular(AppSizes.radius4),
                          ),
                          border: pw.Border.all(
                            color: balance >= 0
                                ? PdfColors.green200
                                : PdfColors.red200,
                          ),
                        ),
                        child: pw.Text(
                          balance >= 0 ? 'SURPLUS' : 'DEFISIT',
                          style: pw.TextStyle(
                            fontSize: AppSizes.font10,
                            fontWeight: pw.FontWeight.bold,
                            color: balance >= 0
                                ? PdfColors.green700
                                : PdfColors.red700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: AppSizes.paddingV16),

            pw.Container(
              padding: pw.EdgeInsets.all(AppSizes.padding16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                border: pw.Border.all(color: PdfColors.grey200),
                borderRadius: pw.BorderRadius.all(
                  pw.Radius.circular(AppSizes.radius8),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'RINGKASAN LENGKAP',
                    style: pw.TextStyle(
                      fontSize: AppSizes.font10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey800,
                    ),
                  ),
                  pw.SizedBox(height: AppSizes.paddingV8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Pemasukan:',
                        style: pw.TextStyle(fontSize: AppSizes.font10),
                      ),
                      pw.Text(
                        idrFormat.format(totalIncome),
                        style: pw.TextStyle(
                          color: PdfColors.green700,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: AppSizes.paddingV4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Pengeluaran:',
                        style: pw.TextStyle(fontSize: AppSizes.font10),
                      ),
                      pw.Text(
                        idrFormat.format(totalExpense),
                        style: pw.TextStyle(
                          color: PdfColors.red700,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Saldo Bersih Keseluruhan:',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      pw.Text(
                        idrFormat.format(balance),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: AppSizes.font14,
                          color: balance >= 0
                              ? PdfColors.green800
                              : PdfColors.red800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: AppSizes.paddingV24),

            pw.Text(
              'JURNAL TRANSAKSI LIFETIME',
              style: pw.TextStyle(
                fontSize: AppSizes.font12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey800,
              ),
            ),
            pw.SizedBox(height: AppSizes.paddingV8),

            if (transactions.isEmpty)
              pw.Text(
                'Tidak ada catatan transaksi sama sekali.',
                style: const pw.TextStyle(color: PdfColors.grey500),
              )
            else
              ...grouped.entries.expand((entry) {
                return [
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.symmetric(
                      vertical: AppSizes.paddingV4,
                      horizontal: AppSizes.padding8,
                    ),
                    color: PdfColors.blueGrey50,
                    child: pw.Text(
                      entry.key,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: AppSizes.font10,
                        color: PdfColors.blueGrey800,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  ...entry.value.map((t) {
                    final isExpense = t.type == 'expense';
                    final amountSign = isExpense ? "-" : "+";
                    return pw.Padding(
                      padding: pw.EdgeInsets.symmetric(
                        vertical: AppSizes.paddingV4,
                        horizontal: AppSizes.padding8,
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  t.title.isNotEmpty
                                      ? t.title
                                      : (t.categoryName ?? 'Transaksi'),
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: AppSizes.font10,
                                  ),
                                ),
                                pw.Text(
                                  '${t.categoryName ?? ''} - ${t.notes ?? ''}',
                                  style: const pw.TextStyle(
                                    fontSize: 8,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Text(
                            '$amountSign${idrFormat.format(t.amount)}',
                            style: pw.TextStyle(
                              fontSize: AppSizes.font10,
                              fontWeight: pw.FontWeight.bold,
                              color: isExpense
                                  ? PdfColors.red700
                                  : PdfColors.green700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  pw.SizedBox(height: 10),
                ];
              }),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> generateAndDownloadAllTimeReport(
    String userName,
    List<TransactionEntity> transactions,
    double totalIncome,
    double totalExpense,
  ) async {
    final pdfBytes = await generateAllTimeReportBytes(
      userName,
      transactions,
      totalIncome,
      totalExpense,
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Laporan_Keuangan_AllTime_${userName.replaceAll(' ', '_')}.pdf',
    );
  }
}
