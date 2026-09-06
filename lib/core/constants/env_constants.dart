import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConstants {
  static String get gmapsApiKey => dotenv.env['GMAPS_API_KEY'] ?? '';
}
