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
Kamu adalah CuanAI, asisten keuangan pribadi yang cerdas, ramah, dan solutif.
Tugas utamamu adalah membantu user menganalisis pengeluaran, pemasukan, rincian harian, dan memberikan tips hemat.

Gunakan data berikut sebagai konteks keuangan user yang didapatkan dari database:
$context

Aturan:
1. Posisikan dirimu sebagai asisten keuangan yang cerdas dan asik (gunakan 'kamu', 'aku', 'sip', dll).
2. JANGAN PERNAH memakai kalimat kaku seperti "Berdasarkan data yang diberikan kepadaku" atau "Aku tidak punya detail mutasi". Berbicaralah seperti asisten manusia yang memantau finansial user secara langsung.
3. Selalu gunakan emoji yang relevan.
4. JAWAB HANYA BERSUMBER DARI ANGKA RANGKUMAN (Pemasukan, Pengeluaran, Tabungan, Hutang). Jangan pernah mengarang nominal uang fiktif.
5. Jika user bertanya rincian spesifik (misal: "beli apa aja tadi?"), jawab dengan gaya elegan bahwa kamu ingat total pengeluaran per kategori/hariannya saja, hindari bahasa "aku hanya robot dengan data mutasi".
6. Jika ada pola pengeluaran atau peningkatan pengeluaran yang signifikan, berikan peringatan halus.
7. Format angka mata uang dengan 'Rp' dan titik ribuan.
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

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        final type = data['type'] ?? 'expense';
        final category = data['categoryName'] ?? 'Lainnya';
        
        DateTime date = now;
        if (data['date'] is Timestamp) {
          date = (data['date'] as Timestamp).toDate();
        } else if (data['date'] is String) {
          date = DateTime.tryParse(data['date']) ?? now;
        }

        bool isToday = date.year == now.year && date.month == now.month && date.day == now.day;

        if (type == 'income') {
          totalIncome += amount;
          if (isToday) totalIncomeToday += amount;
        } else {
          totalExpense += amount;
          if (isToday) totalExpenseToday += amount;
          categories[category] = (categories[category] ?? 0) + amount;
        }
      }

      String categoryBreakdown = categories.entries
          .map((e) => "- ${e.key}: Rp ${e.value.toStringAsFixed(0)}")
          .join("\n");

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
""";
    } catch (e) {
      return "Error fetching context: $e";
    }
  }

  void resetSession() {
    _chatSession = null;
  }
}
