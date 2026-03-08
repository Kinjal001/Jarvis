import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/projects/data/datasources/subtask_local_datasource.dart';
import 'package:jarvis/features/projects/data/datasources/subtask_remote_datasource.dart';
import 'package:jarvis/features/projects/data/repositories/subtask_repository_impl.dart';
import 'package:jarvis/features/projects/domain/entities/subtask.dart';
import 'package:mocktail/mocktail.dart';

class MockSubtaskLocalDatasource extends Mock
    implements SubtaskLocalDatasource {}

class MockSubtaskRemoteDatasource extends Mock
    implements SubtaskRemoteDatasource {}

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

SubtaskRow _makeRow({String id = 's1'}) => SubtaskRow(
  id: id,
  projectId: 'p1',
  title: 'Watch lesson 1',
  isRecurring: false,
  status: 'pending',
  sortOrder: 0,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
  syncStatus: 'synced',
);

void main() {
  late MockSubtaskLocalDatasource local;
  late MockSubtaskRemoteDatasource remote;
  late SubtaskRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(_makeSubtask());
    registerFallbackValue(SubtaskStatus.pending);
    registerFallbackValue(const SubtasksTableCompanion());
  });

  setUp(() {
    local = MockSubtaskLocalDatasource();
    remote = MockSubtaskRemoteDatasource();
    repo = SubtaskRepositoryImpl(local, remote);
  });

  group('getSubtasksByProject', () {
    test('returns mapped list from local', () async {
      when(
        () => local.getByProject('p1'),
      ).thenAnswer((_) async => [_makeRow(), _makeRow(id: 's2')]);

      final result = await repo.getSubtasksByProject('p1');

      expect(result.isRight(), true);
      expect(result.getRight().toNullable()!.length, 2);
      verify(() => local.getByProject('p1')).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.getByProject(any())).thenThrow(Exception('db error'));

      expect(
        await repo.getSubtasksByProject('p1'),
        const Left(Failure.database(message: 'Failed to load subtasks')),
      );
    });
  });

  group('createSubtask', () {
    test('writes locally and returns the subtask', () async {
      final subtask = _makeSubtask();
      when(() => local.upsert(any())).thenAnswer((_) async {});
      when(() => remote.upsert(any())).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      expect(await repo.createSubtask(subtask), Right(subtask));
      verify(() => local.upsert(any())).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.upsert(any())).thenThrow(Exception('error'));

      expect(
        await repo.createSubtask(_makeSubtask()),
        const Left(Failure.database(message: 'Failed to create subtask')),
      );
    });
  });

  group('updateSubtask', () {
    test('returns updated subtask on success', () async {
      final subtask = _makeSubtask();
      when(() => local.upsert(any())).thenAnswer((_) async {});
      when(() => remote.upsert(any())).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      expect(await repo.updateSubtask(subtask), Right(subtask));
    });

    test('returns failure when local throws', () async {
      when(() => local.upsert(any())).thenThrow(Exception('error'));

      expect(
        await repo.updateSubtask(_makeSubtask()),
        const Left(Failure.database(message: 'Failed to update subtask')),
      );
    });
  });

  group('updateSubtaskStatus', () {
    test('calls updateStatus with correct args', () async {
      when(
        () => local.updateStatus('s1', 'completed'),
      ).thenAnswer((_) async {});

      expect(
        await repo.updateSubtaskStatus('s1', SubtaskStatus.completed),
        const Right(unit),
      );
      verify(() => local.updateStatus('s1', 'completed')).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.updateStatus(any(), any())).thenThrow(Exception('err'));

      expect(
        await repo.updateSubtaskStatus('s1', SubtaskStatus.skipped),
        const Left(
          Failure.database(message: 'Failed to update subtask status'),
        ),
      );
    });
  });
}
