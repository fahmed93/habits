import 'package:shared_preferences/shared_preferences.dart';

class TimeService {
  static const String _timeOffsetKey = 'time_offset_hours';
  
  // Singleton pattern
  static final TimeService _instance = TimeService._internal();
  factory TimeService() => _instance;
  TimeService._internal();

  int _offsetHours = 0;

  Future<void> loadOffset() async {
    final prefs = await SharedPreferences.getInstance();
    _offsetHours = prefs.getInt(_timeOffsetKey) ?? 0;
  }

  Future<void> addHours(int hours) async {
    _offsetHours += hours;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeOffsetKey, _offsetHours);
  }

  Future<void> resetOffset() async {
    _offsetHours = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeOffsetKey, 0);
  }

  DateTime now() {
    return DateTime.now().add(Duration(hours: _offsetHours));
  }

  int get offsetHours => _offsetHours;
}
