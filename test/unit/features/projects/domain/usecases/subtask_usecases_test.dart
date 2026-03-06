import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/projects/domain/entities/subtask.dart';
import 'package:jarvis/features/projects/domain/repositories/i_subtask_repository.dart';
import 'package:jarvis/features/projects/domain/usecases/create_subtask.dart';
import 'package:jarvis/features/projects/domain/usecases/get_subtasks_by_project.dart';
import 'package:jarvis/features/projects/domain/usecases/update_subtask.dart';
import 'package:jarvis/features/projects/domain/usecases/update_subtask_status.dart';
import 'package:mocktail/mocktail.dart';

class MockSubtaskRepository extends Mock implements ISubtaskRepository {}

Subtask _makeSubtask({String id = 's1'}) => Subtask(
  id: id,
  projectId: 'p1',
  title: 'Watch lesson 1',
  isRecurring: false,
  status: SubtaskStatus.pending,
  sortOrder: 0,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

void main() {
  late MockSubtaskRepository repo;

  setUpAll(() {
    registerFallbackValue(_makeSubtask());
    registerFallbackValue(SubtaskStatus.pending);
  });
  setUp(() => repo = MockSubtaskRepository());

  group('CreateSubtask', () {
    test('returns created subtask', () async {
      final subtask = _makeSubtask();
      when(
        () => repo.createSubtask(subtask),
      ).thenAnswer((_) async => Right(subtask));

      final result = await CreateSubtask(repo).call(subtask);

      expect(result, Right(subtask));
      verify(() => repo.createSubtask(subtask)).called(1);
    });

    test('returns failure on error', () async {
      const failure = Failure.database(message: 'error');
      when(
        () => repo.createSubtask(any()),
      ).thenAnswer((_) async => const Left(failure));

      expect(
        await CreateSubtask(repo).call(_makeSubtask()),
        const Left(failure),
      );
    });
  });

  group('GetSubtasksByProject', () {
    test('returns subtasks for the given project', () async {
      final subtasks = [_makeSubtask(id: 's1'), _makeSubtask(id: 's2')];
      when(
        () => repo.getSubtasksByProject('p1'),
      ).thenAnswer((_) async => Right(subtasks));

      final result = await GetSubtasksByProject(repo).call('p1');

      expect(result, Right(subtasks));
      verify(() => repo.getSubtasksByProject('p1')).called(1);
    });
  });

  group('UpdateSubtask', () {
    test('delegates updated subtask to repository', () async {
      final updated = _makeSubtask().copyWith(title: 'Watch lesson 2');
      when(
        () => repo.updateSubtask(updated),
      ).thenAnswer((_) async => Right(updated));

      expect(await UpdateSubtask(repo).call(updated), Right(updated));
    });
  });

  group('UpdateSubtaskStatus', () {
    test('calls repository with correct id and status', () async {
      when(
        () => repo.updateSubtaskStatus('s1', SubtaskStatus.completed),
      ).thenAnswer((_) async => const Right(unit));

      final result = await UpdateSubtaskStatus(
        repo,
      ).call('s1', SubtaskStatus.completed);

      expect(result, const Right(unit));
      verify(
        () => repo.updateSubtaskStatus('s1', SubtaskStatus.completed),
      ).called(1);
    });

    test('returns failure when repository fails', () async {
      const failure = Failure.database(message: 'status update failed');
      when(
        () => repo.updateSubtaskStatus(any(), any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await UpdateSubtaskStatus(
        repo,
      ).call('s1', SubtaskStatus.skipped);

      expect(result, const Left(failure));
    });
  });
}
