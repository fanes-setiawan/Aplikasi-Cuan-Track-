import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    // Emit progress from 0 to 100%
    for (int i = 0; i <= 100; i++) {
      emit(SplashLoading(i / 100));
      // Faster delay to make it feel smooth but still visible
      await Future.delayed(const Duration(milliseconds: 30));
    }

    emit(SplashLoaded());
  }
}
