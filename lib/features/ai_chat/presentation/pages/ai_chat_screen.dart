import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_bloc.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_event.dart';
import 'package:cuan_track/features/category/presentation/bloc/category_state.dart';
import 'package:cuan_track/features/home/domain/entities/transaction_entity.dart';
import 'package:cuan_track/features/payment_method/presentation/bloc/payment_method_bloc.dart';
import 'package:cuan_track/features/payment_method/presentation/bloc/payment_method_event.dart';
import 'package:cuan_track/features/payment_method/presentation/bloc/payment_method_state.dart';
import 'package:cuan_track/features/transaction/presentation/bloc/add_transaction_bloc.dart';
import 'package:cuan_track/features/transaction/presentation/bloc/add_transaction_event.dart';
import 'package:cuan_track/features/transaction/presentation/bloc/add_transaction_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:cuan_track/features/transaction/presentation/pages/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/theme/app_styles.dart';
import '../bloc/ai_chat_bloc.dart';
import '../bloc/ai_chat_state.dart';
import '../../../../core/utils/app_helpers.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<CategoryBloc>().add(LoadCategories(user.uid));
      context.read<PaymentMethodBloc>().add(LoadPaymentMethods(user.uid));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF9),
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: SvgPicture.asset(AppAssets.bgSemar, fit: BoxFit.cover),
            ),
          ),
          MultiBlocListener(
            listeners: [
              BlocListener<AIChatBloc, AIChatState>(
                listener: (context, state) {
                  if (state is AIChatLoaded || state is AIChatLoading) {
                    _scrollToBottom();
                  }
                },
              ),
              BlocListener<AddTransactionBloc, AddTransactionState>(
                listener: (context, state) {
                  if (state is AddTransactionSuccess) {
                    AppHelpers.showSnackBar(
                      context,
                      'Transaksi berhasil disimpan! ✅',
                    );
                  } else if (state is AddTransactionFailure) {
                    AppHelpers.showSnackBar(
                      context,
                      'Gagal menyimpan: ${state.message}',
                      isError: true,
                    );
                  }
                },
              ),
            ],
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<AIChatBloc, AIChatState>(
                    builder: (context, state) {
                      if (state.messages.isEmpty && state is! AIChatLoading) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppDimens.md),
                        itemCount:
                            state.messages.length +
                            (state is AIChatLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.messages.length) {
                            return _buildTypingIndicator();
                          }
                          final message = state.messages[index];
                          return _buildMessageBubble(message);
                        },
                      );
                    },
                  ),
                ),
                _buildQuickActions(),
                _buildInputSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.padding8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/icons/ic_boot.svg',
              width: AppSizes.padding24,
              height: AppSizes.paddingV24,
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(width: AppSizes.padding12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asisten AI',
                style: AppStyles.bodyText.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.font16,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: AppSizes.padding8,
                    height: AppSizes.paddingV8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF27AE60),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: AppSizes.padding4),
                  Text(
                    'Online',
                    style: AppStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: AppSizes.font12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.padding20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/icons/ic_boot.svg',
              width: 60,
              height: 60,
              colorFilter: ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(height: AppSizes.paddingV16),
          Text('Halo! Aku CuanAI', style: AppStyles.heading2),
          SizedBox(height: AppSizes.paddingV8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Asisten keuangan pribadimu. Tanya apa saja tentang pengeluaranmu!',
              textAlign: TextAlign.center,
              style: AppStyles.bodyText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[_buildAIAvatar(), SizedBox(width: AppSizes.padding8)],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.padding16, vertical: AppSizes.paddingV12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: _getMessageText(message.text),
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                          p: AppStyles.bodyText.copyWith(
                            color: isUser
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          listBullet: AppStyles.bodyText.copyWith(
                            color: isUser
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          strong: AppStyles.bodyText.copyWith(
                            color: isUser
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          em: AppStyles.bodyText.copyWith(
                            color: isUser
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                  ),
                  if (!isUser && _hasAction(message.text)) ...[
                    SizedBox(height: AppSizes.paddingV12),
                    _buildActionButton(message.text),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[SizedBox(width: AppSizes.padding8), _buildUserAvatar()],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildAIAvatar(),
          SizedBox(width: AppSizes.padding8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.padding16, vertical: AppSizes.paddingV12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SpinKitThreeBounce(
              color: AppColors.primary,
              size: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAvatar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        'assets/icons/ic_boot.svg',
        width: 18,
        height: 18,
        colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person_outline, size: 18, color: Colors.orange),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      'Berapa pengeluaran bulan ini?',
      'Tips hemat belanja',
      'Habis buat apa saja uangku?',
    ];

    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(vertical: AppSizes.paddingV8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (context, index) => SizedBox(width: AppSizes.padding8),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              context.read<AIChatBloc>().add(SendMessageEvent(actions[index]));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.padding16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Text(
                actions[index],
                style: AppStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimens.radiusL),
          topRight: Radius.circular(AppDimens.radiusL),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.textSecondary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTransactionScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: AppSizes.padding12),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.padding16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F7),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Tanyakan sesuatu...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                  onSubmitted: (value) => _sendMessage(),
                ),
              ),
            ),
            SizedBox(width: AppSizes.padding12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: EdgeInsets.all(AppSizes.padding12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      context.read<AIChatBloc>().add(SendMessageEvent(_messageController.text));
      _messageController.clear();
    }
  }

  bool _hasAction(String text) {
    return text.contains('[ACTION:');
  }

  String _getMessageText(String text) {
    if (!_hasAction(text)) return text;
    final actionIndex = text.indexOf('[ACTION:');
    return text.substring(0, actionIndex).trim();
  }

  Map<String, dynamic>? _parseAction(String text) {
    try {
      final regExp = RegExp(r"\[ACTION:(.*)\]");
      final match = regExp.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        final jsonStr = match.group(1)!;
        return json.decode(jsonStr) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Error parsing action tag: $e");
    }
    return null;
  }

  Widget _buildActionButton(String fullText) {
    final action = _parseAction(fullText);
    if (action == null) return const SizedBox.shrink();

    final String type = action['type'] ?? 'expense';
    final double amount = (action['amount'] ?? 0).toDouble();
    final String note = action['note'] ?? '';
    final bool isIncome = type == 'income';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(AppSizes.padding12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radius12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konfirmasi Transaksi:',
            style: AppStyles.caption.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSizes.paddingV8),
          _buildInfoRow(
            Icons.payments_outlined,
            'Nominal',
            AppHelpers.formatCurrencyIdr(amount),
          ),
          _buildInfoRow(Icons.notes, 'Catatan', note.isEmpty ? '-' : note),
          _buildInfoRow(
            isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
            'Tipe',
            isIncome ? 'Pemasukan' : 'Pengeluaran',
            color: isIncome ? AppColors.primary : Colors.orange,
          ),
          SizedBox(height: AppSizes.paddingV12),
          Row(
            children: [
              Expanded(
                child: BlocBuilder<AddTransactionBloc, AddTransactionState>(
                  builder: (context, state) {
                    final isLoading = state is AddTransactionLoading;
                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _submitTransactionDirectly(
                              isIncome,
                              amount,
                              note,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isIncome
                            ? AppColors.primary
                            : Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radius8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Kirim ke Catatan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizes.font12,
                              ),
                            ),
                    );
                  },
                ),
              ),
              SizedBox(width: AppSizes.padding8),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTransactionScreen(
                        isIncome: isIncome,
                        initialAmount: amount,
                        initialNote: note,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note, color: Colors.grey),
                tooltip: 'Edit detail',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 6),
          Text("$label: ", style: AppStyles.caption.copyWith(fontSize: 11)),
          Expanded(
            child: Text(
              value,
              style: AppStyles.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTransactionDirectly(
    bool isIncome,
    double amount,
    String note,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final catState = context.read<CategoryBloc>().state;
    String categoryId = '';
    String categoryName = '';

    if (catState is CategoryLoaded) {
      final relevantCats = catState.categories
          .where((c) => c.type == (isIncome ? 'income' : 'expense'))
          .toList();
      if (relevantCats.isNotEmpty) {
        final defaultCat = relevantCats.firstWhere(
          (c) => c.name.toLowerCase().contains('lainnya'),
          orElse: () => relevantCats.first,
        );
        categoryId = defaultCat.id;
        categoryName = defaultCat.name;
      }
    }

    final pmState = context.read<PaymentMethodBloc>().state;
    String? paymentMethodId;
    if (pmState is PaymentMethodLoaded && pmState.paymentMethods.isNotEmpty) {
      paymentMethodId = pmState.paymentMethods.first.id;
    }

    final entity = TransactionEntity(
      id: '',
      userId: user.uid,
      title: isIncome ? 'Pemasukan AI' : 'Pengeluaran AI',
      amount: amount,
      type: isIncome ? 'income' : 'expense',
      categoryId: categoryId,
      categoryName: categoryName,
      paymentMethodId: paymentMethodId,
      date: DateTime.now(),
      notes: note,
    );

    context.read<AddTransactionBloc>().add(SubmitTransaction(entity));
  }
}
