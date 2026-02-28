import 'package:flutter/material.dart';
import '../../../../core/theme/app_styles.dart';

class PinLockScreen extends StatefulWidget {
  final Function(String) onPinCompleted;
  final VoidCallback onBiometricPressed;
  final VoidCallback? onForgotPin;
  final bool showBiometric;

  const PinLockScreen({
    super.key,
    required this.onPinCompleted,
    required this.onBiometricPressed,
    this.onForgotPin,
    this.showBiometric = true,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _pin = '';
  static const int _pinLength = 4;

  void _onNumberPressed(int number) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin += number.toString();
      });

      if (_pin.length == _pinLength) {
        widget.onPinCompleted(_pin);
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF065F46), // Dark green
              Color(0xFF10B981), // Primary green
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Icon Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFFBBF24), // Amber/Yellow icon
                  size: 40,
                ),
              ),
              const SizedBox(height: 32),
              // Title
              Text(
                'MASUKKAN PIN\nKEAMANAN',
                textAlign: TextAlign.center,
                style: AppStyles.heading2.copyWith(
                  color: Colors.white,
                  letterSpacing: 4,
                  fontSize: 20,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              // PIN Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (index) {
                  final isActive = index < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: const Color(0xFF34D399).withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: -2,
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? const Color(0xFF34D399)
                              : Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),
              // NumPad
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildNumRow([1, 2, 3]),
                    const SizedBox(height: 8),
                    _buildNumRow([4, 5, 6]),
                    const SizedBox(height: 8),
                    _buildNumRow([7, 8, 9]),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBiometricButton(),
                        _buildNumButton(0),
                        _buildDeleteButton(),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Footer
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: widget.onForgotPin,
                      child: Text(
                        'LUPA PIN?',
                        style: AppStyles.caption.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user,
                            color: Color(0xFF34D399),
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SECURE NODE 042',
                            style: AppStyles.caption.copyWith(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      child: Container(
        width: 75,
        height: 75,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (number != 0)
                Text(
                  _getLetters(number),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    if (!widget.showBiometric) return const SizedBox(width: 75, height: 75);
    return InkWell(
      onTap: widget.onBiometricPressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 75,
        height: 75,
        child: Center(
          child: Icon(
            Icons.fingerprint,
            color: Colors.white.withOpacity(0.7),
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _onDeletePressed,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 75,
        height: 75,
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
        ),
      ),
    );
  }

  String _getLetters(int number) {
    switch (number) {
      case 2:
        return 'ABC';
      case 3:
        return 'DEF';
      case 4:
        return 'GHI';
      case 5:
        return 'JKL';
      case 6:
        return 'MNO';
      case 7:
        return 'PQRS';
      case 8:
        return 'TUV';
      case 9:
        return 'WXYZ';
      default:
        return '';
    }
  }
}
