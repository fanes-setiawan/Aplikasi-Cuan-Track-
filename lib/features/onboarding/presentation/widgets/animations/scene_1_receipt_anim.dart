import 'dart:ui';
import 'package:flutter/material.dart';
import 'animated_float_widget.dart';
import 'animated_pulse_glow_widget.dart';

class Scene1ReceiptAnim extends StatefulWidget {
  const Scene1ReceiptAnim({super.key});

  @override
  State<Scene1ReceiptAnim> createState() => _Scene1ReceiptAnimState();
}

class _Scene1ReceiptAnimState extends State<Scene1ReceiptAnim>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2, milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background Glow
          AnimatedPulseGlowWidget(
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10b981).withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10b981).withOpacity(0.3),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // Main Float Group
          AnimatedFloatWidget(
            durationSeconds: 3.0,
            yOffset: -10,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Burger Badge
                Positioned(
                  top: -20,
                  left: -10,
                  child: AnimatedFloatWidget(
                    durationSeconds: 2.0,
                    yOffset: -6,
                    child: _buildFloatingBadge(
                      '🍔',
                      'Rp 35.000',
                      const Color(0xFFfbbf24),
                      const Color(0xFFfcd34d),
                    ),
                  ),
                ),

                // Coffee Badge
                Positioned(
                  bottom: -5,
                  right: -15,
                  child: AnimatedFloatWidget(
                    durationSeconds: 2.0,
                    yOffset: -6,
                    delaySeconds: 1.0,
                    child: _buildFloatingBadge(
                      '☕',
                      'Rp 22.000',
                      const Color(0xFF2dd4bf),
                      const Color(0xFF5eead4),
                    ),
                  ),
                ),

                // Receipt Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1e293b).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF34d399),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Cartoon Eyes
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedPulseGlowWidget(
                                    durationSeconds: 1,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF34d399),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildEye(),
                                  const SizedBox(width: 8),
                                  _buildEye(),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Receipt Details
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF0f172a,
                                  ).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF10b981,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Pantau Harian',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10b981),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Text(
                                            'Aktif',
                                            style: TextStyle(
                                              color: Color(0xFF020617),
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDashedLine(),
                                    const SizedBox(height: 8),
                                    _buildReceiptRow('Kopi Pagi', 'Rp 18.000'),
                                    const SizedBox(height: 4),
                                    _buildReceiptRow(
                                      'Makan Siang',
                                      'Rp 45.000',
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(color: Colors.grey.shade800),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: const [
                                        Text(
                                          'Total Hari Ini',
                                          style: TextStyle(
                                            color: Color(0xFF94a3b8),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Rp 63.000',
                                          style: TextStyle(
                                            color: Color(0xFF34d399),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Scanner Line
                          AnimatedBuilder(
                            animation: _scanController,
                            builder: (context, child) {
                              return Positioned(
                                top: 10 + (_scanController.value * 120),
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34d399),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF34d399,
                                        ).withOpacity(0.8),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Coins Bouncing Below
          Positioned(
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedFloatWidget(
                  durationSeconds: 1.0,
                  yOffset: -15,
                  child: _buildCoin(
                    const Color(0xFFfbbf24),
                    const Color(0xFFfef08a),
                    Icons.monetization_on_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedFloatWidget(
                  durationSeconds: 1.0,
                  yOffset: -15,
                  delaySeconds: 0.3,
                  child: _buildCoin(
                    const Color(0xFF34d399),
                    const Color(0xFFa7f3d0),
                    Icons.savings_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBadge(
    String emoji,
    String text,
    Color borderColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye() {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color(0xFF020617),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFcbd5e1),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Color(0xFF6ee7b7),
            fontSize: 10,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return Row(
      children: List.generate(
        15,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade700,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildCoin(Color bgColor, Color borderColor, IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 16, color: const Color(0xFF020617)),
    );
  }
}
