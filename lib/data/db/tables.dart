import 'package:drift/drift.dart';

class LibraryRoots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text().unique()();
  DateTimeColumn get addedAt => dateTime()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class PlaybackStates extends Table {
  TextColumn get itemId => text()();
  TextColumn get trackId => text()();
  IntColumn get positionMs => integer()();
  RealColumn get speed => real().withDefault(const Constant(1.0))();
  TextColumn get displayTitle => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  IntColumn get durationMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {itemId};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
