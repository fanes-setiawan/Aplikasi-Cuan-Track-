import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {
  final double progress;

  const SplashLoading(this.progress);

  @override
  List<Object> get props => [progress];
}

class SplashLoaded extends SplashState {}
