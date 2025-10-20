import '../models/profile.dart';

class Session {
  static Profile? current;

  static Profile get orDefault => current ?? Profile();
}
