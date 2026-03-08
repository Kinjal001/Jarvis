import 'package:drift/drift.dart';

/// Drift table for Goals.
///
/// Enums are stored as TEXT (their [Enum.name]).
/// [syncStatus] tracks whether the row has been pushed to Supabase:
///   - 'pendingUpload' — written locally, not yet synced
///   - 'synced'        — confirmed in Supabase
@DataClassName('GoalRow')
class GoalsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get intention => text()();
  DateTimeColumn get deadline => dateTime().nullable()();
  IntColumn get priority => integer().withDefault(const Constant(3))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendingUpload'))();

  @override
  Set<Column> get primaryKey => {id};
}
