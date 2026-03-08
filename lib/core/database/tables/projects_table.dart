import 'package:drift/drift.dart';

@DataClassName('ProjectRow')
class ProjectsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();

  /// Null means this project has no parent goal.
  TextColumn get goalId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get deadline => dateTime().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(3))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get resourceLink => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendingUpload'))();

  @override
  Set<Column> get primaryKey => {id};
}
