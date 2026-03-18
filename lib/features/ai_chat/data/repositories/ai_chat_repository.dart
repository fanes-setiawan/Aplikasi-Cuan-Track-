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
        final systemInstruction = """
Kamu adalah CuanAI, asisten keuangan pribadi yang cerdas, ramah, dan solutif.
Tugas utamamu adalah membantu user menganalisis pengeluaran, pemasukan, rincian harian, dan memberikan tips hemat.

Gunakan data berikut sebagai konteks keuangan user yang didapatkan dari database:
$context

Aturan:
1. Jawab dengan gaya bahasa yang santai tapi profesional (gunakan 'kamu', 'aku', 'sip', dll).
2. Selalu gunakan emoji yang relevan.
3. Jawab sesuai fakta data yang diberikan. Jika ditanya "hari ini", cocokkan dengan "Hari ini tanggal" di data.
4. Jika ada pola pengeluaran atau peningkatan pengeluaran yang signifikan, berikan peringatan halus.
5. Format angka mata uang dengan 'Rp' dan titik ribuan.
""";
        
        _chatSession = _model!.startChat(history: [
          Content.text(systemInstruction),
          Content.model([TextPart("Halo! Aku CuanAI, asisten keuanganmu. Bagaimana aku bisa membantumu hari ini? 🤖")])
        ]);
      }

      // 3. Send message
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? "Maaf, aku sedang pusing. Coba tanya lagi ya! 🙏";
    } catch (e) {
      return "Terjadi kesalahan: $e";
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

      if (snapshot.docs.isEmpty) return "User belum memiliki transaksi di bulan ini.";

      double totalIncome = 0;
      double totalExpense = 0;
      Map<String, double> categories = {};

      List<String> transactionDetails = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] ?? 0).toDouble();
        final type = data['type'] ?? 'expense';
        final category = data['categoryName'] ?? 'Lainnya';
        final desc = data['description'] ?? '';
        
        DateTime date = now;
        if (data['date'] is Timestamp) {
          date = (data['date'] as Timestamp).toDate();
        } else if (data['date'] is String) {
          date = DateTime.tryParse(data['date']) ?? now;
        }

        final dateStr = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

        if (type == 'income') {
          totalIncome += amount;
          transactionDetails.add("[$dateStr] Pemasukan: Rp ${amount.toStringAsFixed(0)} ($category) - $desc");
        } else {
          totalExpense += amount;
          categories[category] = (categories[category] ?? 0) + amount;
          transactionDetails.add("[$dateStr] Pengeluaran: Rp ${amount.toStringAsFixed(0)} ($category) - $desc");
        }
      }

      String categoryBreakdown = categories.entries
          .map((e) => "- ${e.key}: Rp ${e.value.toStringAsFixed(0)}")
          .join("\n");
          
      String details = transactionDetails.join("\n");

      return """
INFORMASI WAKTU SAAT INI:
Hari ini tanggal: ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}

RINGKASAN BULAN INI (${now.month}/${now.year}):
- Total Pemasukan: Rp ${totalIncome.toStringAsFixed(0)}
- Total Pengeluaran: Rp ${totalExpense.toStringAsFixed(0)}
- Sisa Saldo: Rp ${(totalIncome - totalExpense).toStringAsFixed(0)}

PENGELUARAN PER KATEGORI:
$categoryBreakdown

RINCIAN PER TRANSAKSI:
$details
""";
    } catch (e) {
      return "Error fetching context: $e";
    }
  }

  void resetSession() {
    _chatSession = null;
  }
}
