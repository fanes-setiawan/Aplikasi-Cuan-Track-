import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIChatRepository {
  GenerativeModel? _model;
  final FirebaseFirestore _firestore;
  ChatSession? _chatSession;

  AIChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> _initModel() async {
    if (_model != null) return;

    // Since App Check is unenforced during development, we omit it here to bypass the
    // DEVELOPER_ERROR caused by missing debug token registration in Firebase Console.
    final ai = await FirebaseAI.googleAI();
    _model = ai.generativeModel(model: 'gemini-2.5-flash');
  }

  Future<String> getAIResponse(String message, String userId) async {
    try {
      await _initModel();

      // 1. Fetch financial context
      final context = await _getFinancialContext(userId);

      // 2. Initialize chat session if null
      if (_chatSession == null) {
        final systemInstruction =
            """
Kamu adalah CuanAI, asisten keuangan pribadi yang sangat cerdas, analitis, sekaligus ramah.
Tugas utamamu adalah membantu pengguna mengelola keuangan dengan bijak, memberikan wawasan mendalam (insights), dan menjawab pertanyaan seputar transaksi mereka dengan detail serta empati.

DATA KEUANGAN PENGGUNA (Gunakan ini sebagai sumber kebenaran):
$context

KEPRIBADIAN & GAYA BICARA:
- Gunakan bahasa yang cerdas, ramah, dan solutif (panggil 'kamu', gunakan 'aku', 'sip', 'mantap').
- Jadilah asisten yang proaktif namun tetap ringkas. Berikan analisis atau tips hanya jika sangat relevan agar tidak bertele-tele.
- Gunakan emoji yang relevan namun proporsional (jangan terlalu banyak).
- JANGAN PERNAH memakai kalimat kaku seperti "Berdasarkan data yang Anda berikan" atau "Saya tidak punya akses ke mutasi". Berbicaralah seolah-olah kamu adalah partner finansial yang memantau catatan keuangan mereka secara langsung.

ATURAN JAWABAN:
1. DETAIL TRANSAKSI: Gunakan bagian 'TRANSAKSI TERAKHIR' (termasuk kolom 'Catatan/Notes') untuk menjawab pertanyaan spesifik tentang riwayat belanja atau sumber uang. Ini kunci agar kamu terlihat paham detail uang user.
2. ANALISIS & TIPS: Jika pengeluaran bulan ini sudah mendekati atau melebihi pemasukan, berikan peringatan halus dan tips hemat yang relevan.
3. FORMAT NOMINAL: Selalu gunakan format 'Rp' dengan titik ribuan (misal: Rp 50.000). JANGAN PERNAH mengarang nominal uang fiktif.
4. KEASLIAN DATA: JANGAN PERNAH menyebutkan data yang tidak ada di database. Jika data tidak ada, beri tahu dengan gaya asisten yang jujur bahwa kamu belum melihat catatan tersebut.
6. KERAPIAN: Gunakan bullet points jika memberikan rincian agar mudah dibaca.
7. SINGKAT & PADAT: Jawablah dengan singkat, padat, dan langsung ke inti (to the point). Jangan memberikan penjelasan yang terlalu panjang atau bertele-tele kecuali diminta rincian mendalam.

ATURAN ACTION (PENTING):
Jika user menyatakan ingin mencatat atau menambah transaksi baru:
1. Konfirmasi detailnya (Nominal, Judul/Catatan, Tipe) di dalam pesan teksmu.
2. Beritahu user untuk menekan tombol **"Kirim ke Catatan"** yang muncul di bawah pesanmu.
3. Sertakan tag di akhir jawabanmu dalam format: [ACTION:{"type":"expense|income", "amount":123000, "note":"beli bakso"}]
- Hanya sertakan tag jika user memang memberitahu transaksi baru.
- Jika nominal tidak jelas, gunakan 0.
- Jangan mengarang data yang tidak disebutkan user.
""";

        _chatSession = _model!.startChat(
          history: [
            Content.text(systemInstruction),
            Content.model([
              TextPart(
                "Halo! Aku CuanAI, asisten keuanganmu. Bagaimana aku bisa membantumu hari ini? 🤖",
              ),
            ]),
          ],
        );
      }

      // 3. Send message
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? "Maaf, aku sedang pusing. Coba tanya lagi ya! 🙏";
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('quota exceeded') || errorStr.contains('429')) {
        return "Waduh, kamu nanyanya terlalu cepat nih (limit gratis tercapai). Kasih aku waktu istirahat sekitar 15 detik ya, baru tanya lagi! ⏳😌";
      } else if (errorStr.contains('offline') ||
          errorStr.contains('network') ||
          errorStr.contains('host')) {
        return "Hmm, sepertinya koneksi internetmu terputus. Pastikan internet lancar lalu coba lagi ya! 📡🔌";
      } else if (errorStr.contains('retired')) {
        return "Wah, otak AI-ku minta di-update nih. Coba hubungi developer ya! 🛠️🤖";
      }
      return "Maaf, sedang ada gangguan teknis sejenak. Silakan coba lagi nanti! 🙏 (Error Code: Sistem sibuk)";
    }
  }

  Future<String> _getFinancialContext(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Get transactions for the current month
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .get();

      if (snapshot.docs.isEmpty)
        return "User belum memiliki transaksi di bulan ini.";

      double totalIncome = 0;
      double totalExpense = 0;
      double totalIncomeToday = 0;
      double totalExpenseToday = 0;
      Map<String, double> categories = {};

      List<String> transactionLogs = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        final type = data['type'] ?? 'expense';
        final category = data['categoryName'] ?? 'Lainnya';
        final title = data['title'] ?? 'Tanpa Judul';
        final notes = data['notes'] ?? '';

        DateTime date = now;
        if (data['date'] is Timestamp) {
          date = (data['date'] as Timestamp).toDate();
        } else if (data['date'] is String) {
          date = DateTime.tryParse(data['date']) ?? now;
        }

        bool isToday =
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

        if (type == 'income') {
          totalIncome += amount;
          if (isToday) totalIncomeToday += amount;
        } else {
          totalExpense += amount;
          if (isToday) totalExpenseToday += amount;
          categories[category] = (categories[category] ?? 0) + amount;
        }

        // Add to logs for detailed context (limit to last 30 for brevity, or sort later)
        String dateStr = "${date.day}/${date.month}";
        String noteStr = notes.isNotEmpty ? " (Catatan: $notes)" : "";
        transactionLogs.add(
          "- [$dateStr] ${type == 'income' ? 'Pemasukan' : 'Pengeluaran'} | $title: Rp ${amount.toStringAsFixed(0)} [$category]$noteStr",
        );
      }

      // Sort logs by date (simple string sort based on current structure or just keep as is if snapshot order is okay)
      // For better result, we could have sorted the snapshot docs by date before loop.
      
      String categoryBreakdown = categories.entries
          .map((e) => "- ${e.key}: Rp ${e.value.toStringAsFixed(0)}")
          .join("\n");

      // Limit transaction logs to a reasonable number to avoid long prompt
      String recentTransactions = transactionLogs.length > 25 
          ? transactionLogs.sublist(transactionLogs.length - 25).join("\n")
          : transactionLogs.join("\n");

      // Fetch Savings
      final savingsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('savings_goals')
          .get();

      List<String> savingsDetails = [];
      for (var doc in savingsSnapshot.docs) {
        final data = doc.data();
        final title = data['title'] ?? '';
        final current = (data['currentAmount'] ?? 0).toDouble();
        final target = (data['targetAmount'] ?? 0).toDouble();
        final isAchieved = data['isAchieved'] ?? false;

        DateTime deadline = now;
        if (data['deadline'] is Timestamp) {
          deadline = (data['deadline'] as Timestamp).toDate();
        }
        final dlStr =
            "${deadline.day.toString().padLeft(2, '0')}/${deadline.month.toString().padLeft(2, '0')}/${deadline.year}";

        savingsDetails.add(
          "- $title: Rp ${current.toStringAsFixed(0)} / Rp ${target.toStringAsFixed(0)} (Target: $dlStr) ${isAchieved ? '[Tercapai]' : ''}",
        );
      }
      String savingsStr = savingsDetails.isEmpty
          ? "Tidak ada data tabungan."
          : savingsDetails.join("\n");

      // Fetch Debts
      final debtSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('debts')
          .get();

      List<String> debtDetails = [];
      for (var doc in debtSnapshot.docs) {
        final data = doc.data();
        final name = data['personName'] ?? '';
        final type = data['type'] ?? 'hutang';
        final amount = (data['amount'] ?? 0).toDouble();
        final paid = (data['paidAmount'] ?? 0).toDouble();
        final isPaid = data['isPaid'] ?? false;

        DateTime due = now;
        if (data['dueDate'] is Timestamp) {
          due = (data['dueDate'] as Timestamp).toDate();
        }
        final dueStr =
            "${due.day.toString().padLeft(2, '0')}/${due.month.toString().padLeft(2, '0')}/${due.year}";

        debtDetails.add(
          "- [$type] $name: Sudah dibayar Rp ${paid.toStringAsFixed(0)} dari Total Rp ${amount.toStringAsFixed(0)} (Jatuh Tempo: $dueStr) ${isPaid ? '[Lunas]' : ''}",
        );
      }
      String debtStr = debtDetails.isEmpty
          ? "Tidak ada data hutang/piutang."
          : debtDetails.join("\n");

      return """
INFORMASI WAKTU SAAT INI:
Hari ini tanggal: ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}

RANGKUMAN HARI INI:
- Pemasukan Hari Ini: Rp ${totalIncomeToday.toStringAsFixed(0)}
- Pengeluaran Hari Ini: Rp ${totalExpenseToday.toStringAsFixed(0)}

RINGKASAN BULAN INI (${now.month}/${now.year}):
- Total Pemasukan: Rp ${totalIncome.toStringAsFixed(0)}
- Total Pengeluaran: Rp ${totalExpense.toStringAsFixed(0)}
- Sisa Saldo: Rp ${(totalIncome - totalExpense).toStringAsFixed(0)}

PENGELUARAN PER KATEGORI:
$categoryBreakdown

DATA TABUNGAN / SAVINGS GOALS:
$savingsStr

DATA HUTANG / PIUTANG:
$debtStr

DAFTAR TRANSAKSI BULAN INI (Termasuk Notes):
$recentTransactions
""";
    } catch (e) {
      return "Error fetching context: $e";
    }
  }

  void resetSession() {
    _chatSession = null;
  }
}
