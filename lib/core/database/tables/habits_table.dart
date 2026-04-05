import 'package:drift/drift.dart';

@DataClassName('HabitRow')
class HabitsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();

  /// 'daily' or 'weekly' — the name of [HabitFrequency] enum values.
  TextColumn get frequency => text()();

  /// Comma-separated ISO 8601 weekday integers, e.g. "1,3,5".
  /// Empty string when [frequency] is daily (unused but always stored).
  TextColumn get targetDaysOfWeek => text().withDefault(const Constant(''))();

  IntColumn get targetCount => integer().withDefault(const Constant(1))();
  TextColumn get colorHex => text().withDefault(const Constant('#7C3AED'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pendingUpload'))();

  @override
  Set<Column> get primaryKey => {id};
}
