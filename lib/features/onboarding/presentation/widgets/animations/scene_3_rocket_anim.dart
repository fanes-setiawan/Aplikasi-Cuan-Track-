import 'dart:ui';
import 'package:flutter/material.dart';
import 'animated_float_widget.dart';
import 'animated_pulse_glow_widget.dart';

class Scene3RocketAnim extends StatelessWidget {
  const Scene3RocketAnim({super.key});

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
                color: const Color(0xFFf59e0b).withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFf59e0b).withOpacity(0.3),
                    blurRadius: 60,
                    spreadRadius: 20,
                  )
                ],
              ),
            ),
          ),
          
          // Main Float Group
          AnimatedFloatWidget(
            durationSeconds: 3.5,
            yOffset: -12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e293b).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFfbbf24),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Floating Trophy & Rocket
                      SizedBox(
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Trophy
                            AnimatedFloatWidget(
                              durationSeconds: 2.0,
                              yOffset: -6,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFfbbf24), Color(0xFFfde047), Color(0xFFf59e0b)],
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                  ),
                                  border: Border.all(color: const Color(0xFFfde047), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFf59e0b).withOpacity(0.3),
                                      blurRadius: 15,
                                    )
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Text('🏆', style: TextStyle(fontSize: 36)),
                              ),
                            ),
                            
                            // Flying Piggy Rocket
                            Positioned(
                              top: -10,
                              right: 0,
                              child: AnimatedFloatWidget(
                                durationSeconds: 3.0,
                                yOffset: -15,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0f172a).withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFf472b6), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text('🚀 ', style: TextStyle(fontSize: 12)),
                                      Text('Piggy Rocket', style: TextStyle(color: Color(0xFFf9a8d4), fontSize: 10, fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Stars
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: AnimatedPulseGlowWidget(
                                durationSeconds: 1.5,
                                maxScale: 1.2,
                                child: const Text('⭐', style: TextStyle(fontSize: 20)),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              left: 30,
                              child: AnimatedPulseGlowWidget(
                                durationSeconds: 0.8,
                                maxScale: 1.5,
                                child: const Text('✨', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Goal Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0f172a).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFf59e0b).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text('Impian Finansial Terwujud', style: TextStyle(color: Color(0xFFfcd34d), fontSize: 12, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            const Text('Rencana Matang & Terukur', style: TextStyle(color: Color(0xFFcbd5e1), fontSize: 10)),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10b981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF10b981).withOpacity(0.3)),
                              ),
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text('Tabungan: ', style: TextStyle(color: Color(0xFF34d399), fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                                    Text('Rp 10.000.000+', style: TextStyle(color: Color(0xFF34d399), fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
