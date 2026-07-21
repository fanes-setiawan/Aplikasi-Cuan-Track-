import 'package:cuan_track/core/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/utils/app_helpers.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  String _firstPin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  static const int _pinLength = 4;

  void _onNumberPressed(int number) {
    setState(() {
      if (!_isConfirming) {
        if (_firstPin.length < _pinLength) {
          _firstPin += number.toString();
          if (_firstPin.length == _pinLength) {
            _isConfirming = true;
          }
        }
      } else {
        if (_confirmPin.length < _pinLength) {
          _confirmPin += number.toString();
          if (_confirmPin.length == _pinLength) {
            _verifyAndSave();
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (!_isConfirming) {
        if (_firstPin.isNotEmpty) {
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
        }
      } else {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        } else {
          _isConfirming = false;
          _firstPin = _firstPin.substring(0, _firstPin.length - 1);
        }
      }
    });
  }

  Future<void> _verifyAndSave() async {
    if (_firstPin == _confirmPin) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userPin', _firstPin);
      await prefs.setBool('pinEnabled', true);

      if (mounted) {
        AppHelpers.showSnackBar(context, 'PIN berhasil disimpan!');
        Navigator.pop(context, true);
      }
    } else {
      AppHelpers.showSnackBar(
        context,
        'PIN tidak cocok, silakan coba lagi',
        isError: true,
      );
      setState(() {
        _firstPin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPinDisplay = _isConfirming ? _confirmPin : _firstPin;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(
              _isConfirming ? Icons.verified_user_outlined : Icons.lock_outline,
              size: 64,
              color: AppColors.primary,
            ),
            SizedBox(height: AppSizes.paddingV24),
            Text(
              _isConfirming ? 'Konfirmasi PIN Baru' : 'Setel PIN Baru',
              style: AppStyles.heading1.copyWith(fontSize: AppSizes.font24),
            ),
            SizedBox(height: AppSizes.paddingV8),
            Text(
              _isConfirming
                  ? 'Masukkan kembali 4 digit PIN Anda'
                  : 'Pilih 4 digit angka untuk mengamankan data Anda',
              style: AppStyles.bodyTextSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pinLength, (index) {
                final isActive = index < currentPinDisplay.length;
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: AppSizes.padding12),
                  width: AppSizes.padding16,
                  height: AppSizes.paddingV16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.primary : AppColors.divider,
                  ),
                );
              }),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: AppSizes.paddingV24),
              child: Column(
                children: [
                  _buildNumRow([1, 2, 3]),
                  SizedBox(height: AppSizes.paddingV24),
                  _buildNumRow([4, 5, 6]),
                  SizedBox(height: AppSizes.paddingV24),
                  _buildNumRow([7, 8, 9]),
                  SizedBox(height: AppSizes.paddingV24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 80),
                      _buildNumButton(0),
                      _buildDeleteButton(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNumRow(List<int> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: numbers.map((n) => _buildNumButton(n)).toList(),
    );
  }

  Widget _buildNumButton(int number) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(50),
      child: SizedBox(
        width: 80,
        height: 80,
        child: Center(
          child: Text(
            number.toString(),
            style: AppStyles.heading1.copyWith(fontSize: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _onDeletePressed,
      borderRadius: BorderRadius.circular(50),
      child: const SizedBox(
        width: 80,
        height: 80,
        child: Center(child: Icon(Icons.backspace_outlined, size: 24)),
      ),
    );
  }
}
