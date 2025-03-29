export 'shakkelha/model.dart';

abstract class Vowelizer {
  String vowelize(String text);
  void initSessions({String modelPath});
  void release();
}
