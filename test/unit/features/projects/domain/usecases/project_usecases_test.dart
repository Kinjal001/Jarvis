import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jarvis/core/error/failures.dart';
import 'package:jarvis/features/projects/domain/entities/project.dart';
import 'package:jarvis/features/projects/domain/repositories/i_project_repository.dart';
import 'package:jarvis/features/projects/domain/usecases/archive_project.dart';
import 'package:jarvis/features/projects/domain/usecases/create_project.dart';
import 'package:jarvis/features/projects/domain/usecases/get_projects.dart';
import 'package:jarvis/features/projects/domain/usecases/get_projects_by_goal.dart';
import 'package:jarvis/features/projects/domain/usecases/update_project.dart';
import 'package:mocktail/mocktail.dart';

class MockProjectRepository extends Mock implements IProjectRepository {}

Project _makeProject({String id = 'p1', String? goalId}) => Project(
  id: id,
  userId: 'user-1',
  goalId: goalId,
  title: 'Complete Fast.ai',
  priority: 1,
  status: ProjectStatus.active,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

void main() {
  late MockProjectRepository repo;

  setUpAll(() => registerFallbackValue(_makeProject()));
  setUp(() => repo = MockProjectRepository());

  group('CreateProject', () {
    test('returns created project', () async {
      final project = _makeProject();
      when(
        () => repo.createProject(project),
      ).thenAnswer((_) async => Right(project));

      final result = await CreateProject(repo).call(project);

      expect(result, Right(project));
      verify(() => repo.createProject(project)).called(1);
    });

    test('returns failure on error', () async {
      const failure = Failure.database(message: 'error');
      when(
        () => repo.createProject(any()),
      ).thenAnswer((_) async => const Left(failure));

      expect(
        await CreateProject(repo).call(_makeProject()),
        const Left(failure),
      );
    });
  });

  group('GetProjects', () {
    test('returns all projects', () async {
      final projects = [_makeProject(id: 'p1'), _makeProject(id: 'p2')];
      when(() => repo.getProjects()).thenAnswer((_) async => Right(projects));

      expect(await GetProjects(repo).call(), Right(projects));
    });
  });

  group('GetProjectsByGoal', () {
    test('returns projects filtered by goalId', () async {
      final projects = [_makeProject(goalId: 'g1')];
      when(
        () => repo.getProjectsByGoal('g1'),
      ).thenAnswer((_) async => Right(projects));

      final result = await GetProjectsByGoal(repo).call('g1');

      expect(result, Right(projects));
      verify(() => repo.getProjectsByGoal('g1')).called(1);
    });
  });

  group('UpdateProject', () {
    test('delegates to repository', () async {
      final updated = _makeProject().copyWith(title: 'Updated');
      when(
        () => repo.updateProject(updated),
      ).thenAnswer((_) async => Right(updated));

      expect(await UpdateProject(repo).call(updated), Right(updated));
    });
  });

  group('ArchiveProject', () {
    test('calls archiveProject with correct id', () async {
      when(
        () => repo.archiveProject('p1'),
      ).thenAnswer((_) async => const Right(unit));

      final result = await ArchiveProject(repo).call('p1');

      expect(result, const Right(unit));
      verify(() => repo.archiveProject('p1')).called(1);
    });
  });
}
