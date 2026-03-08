import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/database/app_database.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/projects/data/datasources/project_local_datasource.dart';
import 'package:jarvis/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:jarvis/features/projects/data/repositories/project_repository_impl.dart';
import 'package:jarvis/features/projects/domain/entities/project.dart';
import 'package:mocktail/mocktail.dart';

class MockProjectLocalDatasource extends Mock
    implements ProjectLocalDatasource {}

class MockProjectRemoteDatasource extends Mock
    implements ProjectRemoteDatasource {}

Project _makeProject({String id = 'p1', String? goalId}) => Project(
  id: id,
  userId: 'u1',
  goalId: goalId,
  title: 'Complete Fast.ai',
  priority: 1,
  status: ProjectStatus.active,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

ProjectRow _makeRow({String id = 'p1'}) => ProjectRow(
  id: id,
  userId: 'u1',
  goalId: null,
  title: 'Complete Fast.ai',
  priority: 1,
  status: 'active',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
  syncStatus: 'synced',
);

void main() {
  late MockProjectLocalDatasource local;
  late MockProjectRemoteDatasource remote;
  late ProjectRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(_makeProject());
    registerFallbackValue(const ProjectsTableCompanion());
  });

  setUp(() {
    local = MockProjectLocalDatasource();
    remote = MockProjectRemoteDatasource();
    repo = ProjectRepositoryImpl(local, remote);
  });

  group('getProjects', () {
    test('returns mapped list from local', () async {
      when(
        () => local.getAll(),
      ).thenAnswer((_) async => [_makeRow(), _makeRow(id: 'p2')]);

      final result = await repo.getProjects();

      expect(result.isRight(), true);
      expect(result.getRight().toNullable()!.length, 2);
    });

    test('returns failure when local throws', () async {
      when(() => local.getAll()).thenThrow(Exception('db error'));

      expect(
        await repo.getProjects(),
        const Left(Failure.database(message: 'Failed to load projects')),
      );
    });
  });

  group('getProjectsByGoal', () {
    test('returns projects filtered by goalId', () async {
      when(() => local.getByGoal('g1')).thenAnswer((_) async => [_makeRow()]);

      final result = await repo.getProjectsByGoal('g1');

      expect(result.isRight(), true);
      verify(() => local.getByGoal('g1')).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.getByGoal(any())).thenThrow(Exception('db error'));

      expect(
        await repo.getProjectsByGoal('g1'),
        const Left(
          Failure.database(message: 'Failed to load projects for goal'),
        ),
      );
    });
  });

  group('createProject', () {
    test('writes locally and returns the project', () async {
      final project = _makeProject();
      when(() => local.upsert(any())).thenAnswer((_) async {});
      when(() => remote.upsert(any())).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      expect(await repo.createProject(project), Right(project));
      verify(() => local.upsert(any())).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.upsert(any())).thenThrow(Exception('error'));

      expect(
        await repo.createProject(_makeProject()),
        const Left(Failure.database(message: 'Failed to create project')),
      );
    });
  });

  group('updateProject', () {
    test('returns updated project on success', () async {
      final project = _makeProject();
      when(() => local.upsert(any())).thenAnswer((_) async {});
      when(() => remote.upsert(any())).thenAnswer((_) async {});
      when(() => local.markSynced(any())).thenAnswer((_) async {});

      expect(await repo.updateProject(project), Right(project));
    });

    test('returns failure when local throws', () async {
      when(() => local.upsert(any())).thenThrow(Exception('error'));

      expect(
        await repo.updateProject(_makeProject()),
        const Left(Failure.database(message: 'Failed to update project')),
      );
    });
  });

  group('archiveProject', () {
    test('updates status to archived and returns unit', () async {
      when(() => local.updateStatus('p1', 'archived')).thenAnswer((_) async {});

      expect(await repo.archiveProject('p1'), const Right(unit));
      verify(() => local.updateStatus('p1', 'archived')).called(1);
    });

    test('returns failure when local throws', () async {
      when(() => local.updateStatus(any(), any())).thenThrow(Exception('err'));

      expect(
        await repo.archiveProject('p1'),
        const Left(Failure.database(message: 'Failed to archive project')),
      );
    });
  });
}
