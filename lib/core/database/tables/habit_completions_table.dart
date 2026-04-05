import 'package:drift/drift.dart';

@DataClassName('HabitCompletionRow')
class HabitCompletionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get habitId => text()();
  TextColumn get userId => text()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendingUpload'))();

  @override
  Set<Column> get primaryKey => {id};
}
