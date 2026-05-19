import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge/domain/entities/workout_day.dart';
import 'package:forge/domain/entities/workout_session.dart';
import 'package:forge/domain/repositories/workout_repository.dart';
import 'package:forge/presentation/providers/workout_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}
class WorkoutSessionFake extends Fake implements WorkoutSession {}

void main() {
  late MockWorkoutRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(WorkoutSessionFake());
  });

  setUp(() {
    mockRepository = MockWorkoutRepository();
    container = ProviderContainer(
      overrides: [
        workoutRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('streakProvider', () {
    test('returns 0 when there are no sessions', () async {
      when(() => mockRepository.getWorkoutHistory()).thenAnswer((_) async => []);
      when(() => mockRepository.getWorkoutDays()).thenAnswer((_) async => []);

      final streak = container.read(streakProvider);
      expect(streak, 0);
    });

    test('calculates correct streak with consecutive workout days', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      final days = [
        WorkoutDay(id: '1', name: 'Push', dayOrder: 0, targetMuscles: ['Chest'], workoutType: 'push', scheduledDay: today.weekday - 1),
        WorkoutDay(id: '2', name: 'Pull', dayOrder: 1, targetMuscles: ['Back'], workoutType: 'pull', scheduledDay: yesterday.weekday - 1),
      ];

      final sessions = [
        WorkoutSession(id: 's1', date: today, workoutDayId: '1', durationMinutes: 45, completed: true),
        WorkoutSession(id: 's2', date: yesterday, workoutDayId: '2', durationMinutes: 45, completed: true),
      ];

      when(() => mockRepository.getWorkoutHistory()).thenAnswer((_) async => sessions);
      when(() => mockRepository.getWorkoutDays()).thenAnswer((_) async => days);

      // Trigger the providers
      await container.read(workoutHistoryProvider.future);
      await container.read(workoutDaysProvider.future);

      final streak = container.read(streakProvider);
      expect(streak, 2);
    });

    test('includes rest days in streak calculation', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      final days = [
        WorkoutDay(id: '1', name: 'Push', dayOrder: 0, targetMuscles: ['Chest'], workoutType: 'push', scheduledDay: today.weekday - 1),
        WorkoutDay(id: '2', name: 'Rest', dayOrder: 1, targetMuscles: [], workoutType: 'rest', scheduledDay: yesterday.weekday - 1),
      ];

      final sessions = [
        WorkoutSession(id: 's1', date: today, workoutDayId: '1', durationMinutes: 45, completed: true),
      ];

      when(() => mockRepository.getWorkoutHistory()).thenAnswer((_) async => sessions);
      when(() => mockRepository.getWorkoutDays()).thenAnswer((_) async => days);

      await container.read(workoutHistoryProvider.future);
      await container.read(workoutDaysProvider.future);

      final streak = container.read(streakProvider);
      // Streak should be 2 because yesterday was a scheduled rest day
      expect(streak, 2);
    });
  });

  group('workoutHistoryProvider', () {
    test('auto-logs rest days missing in history within last 7 days', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      
      // Setup: Yesterday is a rest day, but no session logged for it
      final days = [
        WorkoutDay(id: 'rest_day', name: 'Rest', dayOrder: 0, targetMuscles: [], workoutType: 'rest', scheduledDay: yesterday.weekday - 1),
      ];

      when(() => mockRepository.getWorkoutHistory()).thenAnswer((_) async => []);
      when(() => mockRepository.getWorkoutDays()).thenAnswer((_) async => days);
      when(() => mockRepository.saveWorkoutSession(any())).thenAnswer((_) async => {});

      final result = await container.read(workoutHistoryProvider.future);

      // Verify that saveWorkoutSession was called for the rest day
      verify(() => mockRepository.saveWorkoutSession(any())).called(greaterThanOrEqualTo(1));
    });
  });
}
