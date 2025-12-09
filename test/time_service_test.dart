import 'package:flutter_test/flutter_test.dart';
import 'package:habits/services/time_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimeService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('TimeService should be a singleton', () {
      final instance1 = TimeService();
      final instance2 = TimeService();

      expect(identical(instance1, instance2), true);
    });

    test('loadOffset should initialize offset to 0 when no data exists',
        () async {
      final service = TimeService();
      await service.loadOffset();

      expect(service.offsetHours, 0);
    });

    test('addHours should increase the offset', () async {
      final service = TimeService();
      await service.loadOffset();

      await service.addHours(2);

      expect(service.offsetHours, 2);
    });

    test('addHours should accumulate multiple additions', () async {
      final service = TimeService();
      await service.loadOffset();

      await service.addHours(1);
      await service.addHours(2);
      await service.addHours(3);

      expect(service.offsetHours, 6);
    });

    test('addHours should handle negative values', () async {
      final service = TimeService();
      await service.loadOffset();

      await service.addHours(5);
      await service.addHours(-2);

      expect(service.offsetHours, 3);
    });

    test('resetOffset should reset offset to 0', () async {
      final service = TimeService();
      await service.loadOffset();

      await service.addHours(10);
      expect(service.offsetHours, 10);

      await service.resetOffset();
      expect(service.offsetHours, 0);
    });

    test('now should return current time with no offset initially', () async {
      final service = TimeService();
      await service.loadOffset();

      final now = service.now();
      final actualNow = DateTime.now();

      // Allow 2 seconds difference for test execution time
      expect(now.difference(actualNow).abs().inSeconds < 2, true);
    });

    test('now should return adjusted time with positive offset', () async {
      final service = TimeService();
      await service.loadOffset();

      await service.addHours(5);
      
      final now = service.now();
      final expectedTime = DateTime.now().add(const Duration(hours: 5));

      // Allow 2 seconds difference for test execution time
      expect(now.difference(expectedTime).abs().inSeconds < 2, true);
    });

    test('now should return adjusted time with negative offset', () async {
      final service = TimeService();
      await service.loadOffset();

      await service.addHours(-3);
      
      final now = service.now();
      final expectedTime = DateTime.now().add(const Duration(hours: -3));

      // Allow 2 seconds difference for test execution time
      expect(now.difference(expectedTime).abs().inSeconds < 2, true);
    });

    test('offset should persist across service instances', () async {
      final service1 = TimeService();
      await service1.loadOffset();
      await service1.addHours(4);

      // Simulate app restart by creating a new instance and loading
      final service2 = TimeService();
      await service2.loadOffset();

      expect(service2.offsetHours, 4);
    });

    test('resetOffset should persist to storage', () async {
      final service = TimeService();
      await service.loadOffset();
      await service.addHours(8);
      await service.resetOffset();

      // Verify persistence
      final prefs = await SharedPreferences.getInstance();
      final storedOffset = prefs.getInt('time_offset_hours');
      expect(storedOffset, 0);
    });

    test('addHours should persist to storage', () async {
      final service = TimeService();
      await service.loadOffset();
      await service.addHours(7);

      // Verify persistence
      final prefs = await SharedPreferences.getInstance();
      final storedOffset = prefs.getInt('time_offset_hours');
      expect(storedOffset, 7);
    });

    test('offsetHours getter should return current offset', () async {
      final service = TimeService();
      await service.loadOffset();

      expect(service.offsetHours, 0);

      await service.addHours(12);
      expect(service.offsetHours, 12);

      await service.addHours(-5);
      expect(service.offsetHours, 7);
    });
  });
}
