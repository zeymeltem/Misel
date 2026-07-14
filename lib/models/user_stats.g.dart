// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetUserStatsCollection on Isar {
  IsarCollection<int, UserStats> get userStats => this.collection();
}

final UserStatsSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'UserStats',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'totalCoins', type: IsarType.long),
      IsarPropertySchema(name: 'currentStreak', type: IsarType.long),
      IsarPropertySchema(name: 'longestStreak', type: IsarType.long),
      IsarPropertySchema(name: 'lastSuccessDate', type: IsarType.dateTime),
      IsarPropertySchema(name: 'lastOpenDate', type: IsarType.dateTime),
      IsarPropertySchema(name: 'selectedMushroomTypeId', type: IsarType.long),
      IsarPropertySchema(name: 'displayName', type: IsarType.string),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, UserStats>(
    serialize: serializeUserStats,
    deserialize: deserializeUserStats,
    deserializeProperty: deserializeUserStatsProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeUserStats(IsarWriter writer, UserStats object) {
  IsarCore.writeLong(writer, 1, object.totalCoins);
  IsarCore.writeLong(writer, 2, object.currentStreak);
  IsarCore.writeLong(writer, 3, object.longestStreak);
  IsarCore.writeLong(
    writer,
    4,
    object.lastSuccessDate?.toUtc().microsecondsSinceEpoch ??
        -9223372036854775808,
  );
  IsarCore.writeLong(
    writer,
    5,
    object.lastOpenDate?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808,
  );
  IsarCore.writeLong(
    writer,
    6,
    object.selectedMushroomTypeId ?? -9223372036854775808,
  );
  {
    final value = object.displayName;
    if (value == null) {
      IsarCore.writeNull(writer, 7);
    } else {
      IsarCore.writeString(writer, 7, value);
    }
  }
  return object.id;
}

@isarProtected
UserStats deserializeUserStats(IsarReader reader) {
  final object = UserStats();
  object.id = IsarCore.readId(reader);
  object.totalCoins = IsarCore.readLong(reader, 1);
  object.currentStreak = IsarCore.readLong(reader, 2);
  object.longestStreak = IsarCore.readLong(reader, 3);
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      object.lastSuccessDate = null;
    } else {
      object.lastSuccessDate = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      object.lastOpenDate = null;
    } else {
      object.lastOpenDate = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  {
    final value = IsarCore.readLong(reader, 6);
    if (value == -9223372036854775808) {
      object.selectedMushroomTypeId = null;
    } else {
      object.selectedMushroomTypeId = value;
    }
  }
  object.displayName = IsarCore.readString(reader, 7);
  return object;
}

@isarProtected
dynamic deserializeUserStatsProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readLong(reader, 1);
    case 2:
      return IsarCore.readLong(reader, 2);
    case 3:
      return IsarCore.readLong(reader, 3);
    case 4:
      {
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 6:
      {
        final value = IsarCore.readLong(reader, 6);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 7:
      return IsarCore.readString(reader, 7);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _UserStatsUpdate {
  bool call({
    required int id,
    int? totalCoins,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastSuccessDate,
    DateTime? lastOpenDate,
    int? selectedMushroomTypeId,
    String? displayName,
  });
}

class _UserStatsUpdateImpl implements _UserStatsUpdate {
  const _UserStatsUpdateImpl(this.collection);

  final IsarCollection<int, UserStats> collection;

  @override
  bool call({
    required int id,
    Object? totalCoins = ignore,
    Object? currentStreak = ignore,
    Object? longestStreak = ignore,
    Object? lastSuccessDate = ignore,
    Object? lastOpenDate = ignore,
    Object? selectedMushroomTypeId = ignore,
    Object? displayName = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (totalCoins != ignore) 1: totalCoins as int?,
            if (currentStreak != ignore) 2: currentStreak as int?,
            if (longestStreak != ignore) 3: longestStreak as int?,
            if (lastSuccessDate != ignore) 4: lastSuccessDate as DateTime?,
            if (lastOpenDate != ignore) 5: lastOpenDate as DateTime?,
            if (selectedMushroomTypeId != ignore)
              6: selectedMushroomTypeId as int?,
            if (displayName != ignore) 7: displayName as String?,
          },
        ) >
        0;
  }
}

sealed class _UserStatsUpdateAll {
  int call({
    required List<int> id,
    int? totalCoins,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastSuccessDate,
    DateTime? lastOpenDate,
    int? selectedMushroomTypeId,
    String? displayName,
  });
}

class _UserStatsUpdateAllImpl implements _UserStatsUpdateAll {
  const _UserStatsUpdateAllImpl(this.collection);

  final IsarCollection<int, UserStats> collection;

  @override
  int call({
    required List<int> id,
    Object? totalCoins = ignore,
    Object? currentStreak = ignore,
    Object? longestStreak = ignore,
    Object? lastSuccessDate = ignore,
    Object? lastOpenDate = ignore,
    Object? selectedMushroomTypeId = ignore,
    Object? displayName = ignore,
  }) {
    return collection.updateProperties(id, {
      if (totalCoins != ignore) 1: totalCoins as int?,
      if (currentStreak != ignore) 2: currentStreak as int?,
      if (longestStreak != ignore) 3: longestStreak as int?,
      if (lastSuccessDate != ignore) 4: lastSuccessDate as DateTime?,
      if (lastOpenDate != ignore) 5: lastOpenDate as DateTime?,
      if (selectedMushroomTypeId != ignore) 6: selectedMushroomTypeId as int?,
      if (displayName != ignore) 7: displayName as String?,
    });
  }
}

extension UserStatsUpdate on IsarCollection<int, UserStats> {
  _UserStatsUpdate get update => _UserStatsUpdateImpl(this);

  _UserStatsUpdateAll get updateAll => _UserStatsUpdateAllImpl(this);
}

sealed class _UserStatsQueryUpdate {
  int call({
    int? totalCoins,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastSuccessDate,
    DateTime? lastOpenDate,
    int? selectedMushroomTypeId,
    String? displayName,
  });
}

class _UserStatsQueryUpdateImpl implements _UserStatsQueryUpdate {
  const _UserStatsQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<UserStats> query;
  final int? limit;

  @override
  int call({
    Object? totalCoins = ignore,
    Object? currentStreak = ignore,
    Object? longestStreak = ignore,
    Object? lastSuccessDate = ignore,
    Object? lastOpenDate = ignore,
    Object? selectedMushroomTypeId = ignore,
    Object? displayName = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (totalCoins != ignore) 1: totalCoins as int?,
      if (currentStreak != ignore) 2: currentStreak as int?,
      if (longestStreak != ignore) 3: longestStreak as int?,
      if (lastSuccessDate != ignore) 4: lastSuccessDate as DateTime?,
      if (lastOpenDate != ignore) 5: lastOpenDate as DateTime?,
      if (selectedMushroomTypeId != ignore) 6: selectedMushroomTypeId as int?,
      if (displayName != ignore) 7: displayName as String?,
    });
  }
}

extension UserStatsQueryUpdate on IsarQuery<UserStats> {
  _UserStatsQueryUpdate get updateFirst =>
      _UserStatsQueryUpdateImpl(this, limit: 1);

  _UserStatsQueryUpdate get updateAll => _UserStatsQueryUpdateImpl(this);
}

class _UserStatsQueryBuilderUpdateImpl implements _UserStatsQueryUpdate {
  const _UserStatsQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<UserStats, UserStats, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? totalCoins = ignore,
    Object? currentStreak = ignore,
    Object? longestStreak = ignore,
    Object? lastSuccessDate = ignore,
    Object? lastOpenDate = ignore,
    Object? selectedMushroomTypeId = ignore,
    Object? displayName = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (totalCoins != ignore) 1: totalCoins as int?,
        if (currentStreak != ignore) 2: currentStreak as int?,
        if (longestStreak != ignore) 3: longestStreak as int?,
        if (lastSuccessDate != ignore) 4: lastSuccessDate as DateTime?,
        if (lastOpenDate != ignore) 5: lastOpenDate as DateTime?,
        if (selectedMushroomTypeId != ignore) 6: selectedMushroomTypeId as int?,
        if (displayName != ignore) 7: displayName as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension UserStatsQueryBuilderUpdate
    on QueryBuilder<UserStats, UserStats, QOperations> {
  _UserStatsQueryUpdate get updateFirst =>
      _UserStatsQueryBuilderUpdateImpl(this, limit: 1);

  _UserStatsQueryUpdate get updateAll => _UserStatsQueryBuilderUpdateImpl(this);
}

extension UserStatsQueryFilter
    on QueryBuilder<UserStats, UserStats, QFilterCondition> {
  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> totalCoinsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  totalCoinsGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  totalCoinsGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> totalCoinsLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 1, value: value));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  totalCoinsLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> totalCoinsBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 1, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  currentStreakGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  currentStreakGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  currentStreakLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 2, value: value));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  currentStreakLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  currentStreakBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 2, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  longestStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  longestStreakGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  longestStreakGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  longestStreakLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 3, value: value));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  longestStreakLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  longestStreakBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 3, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastSuccessDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastSuccessDateIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 4));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastSuccessDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastSuccessDateGreaterThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastSuccessDateGreaterThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastSuccessDateLessThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 4, value: value));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastSuccessDateLessThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastSuccessDateBetween(DateTime? lower, DateTime? upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 4, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastOpenDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastOpenDateIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> lastOpenDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastOpenDateGreaterThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastOpenDateGreaterThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastOpenDateLessThan(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 5, value: value));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastOpenDateLessThanOrEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> lastOpenDateBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 5, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  selectedMushroomTypeIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  selectedMushroomTypeIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  selectedMushroomTypeIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  selectedMushroomTypeIdGreaterThan(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  selectedMushroomTypeIdGreaterThanOrEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  selectedMushroomTypeIdLessThan(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 6, value: value));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  selectedMushroomTypeIdLessThanOrEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  selectedMushroomTypeIdBetween(int? lower, int? upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 6, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  displayNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  displayNameIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> displayNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  displayNameGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  displayNameGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> displayNameLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 7, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  displayNameLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> displayNameBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  displayNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> displayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> displayNameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> displayNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 7,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 7, value: ''),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 7, value: ''),
      );
    });
  }
}

extension UserStatsQueryObject
    on QueryBuilder<UserStats, UserStats, QFilterCondition> {}

extension UserStatsQuerySortBy on QueryBuilder<UserStats, UserStats, QSortBy> {
  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByTotalCoins() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByTotalCoinsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByLongestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByLongestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByLastSuccessDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByLastSuccessDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByLastOpenDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByLastOpenDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy>
  sortBySelectedMushroomTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy>
  sortBySelectedMushroomTypeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByDisplayName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByDisplayNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension UserStatsQuerySortThenBy
    on QueryBuilder<UserStats, UserStats, QSortThenBy> {
  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByTotalCoins() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByTotalCoinsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByLongestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByLongestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByLastSuccessDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByLastSuccessDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByLastOpenDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByLastOpenDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy>
  thenBySelectedMushroomTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy>
  thenBySelectedMushroomTypeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByDisplayName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByDisplayNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension UserStatsQueryWhereDistinct
    on QueryBuilder<UserStats, UserStats, QDistinct> {
  QueryBuilder<UserStats, UserStats, QAfterDistinct> distinctByTotalCoins() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterDistinct> distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterDistinct> distinctByLongestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterDistinct>
  distinctByLastSuccessDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterDistinct> distinctByLastOpenDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterDistinct>
  distinctBySelectedMushroomTypeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterDistinct> distinctByDisplayName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7, caseSensitive: caseSensitive);
    });
  }
}

extension UserStatsQueryProperty1
    on QueryBuilder<UserStats, UserStats, QProperty> {
  QueryBuilder<UserStats, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<UserStats, int, QAfterProperty> totalCoinsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<UserStats, int, QAfterProperty> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<UserStats, int, QAfterProperty> longestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<UserStats, DateTime?, QAfterProperty> lastSuccessDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<UserStats, DateTime?, QAfterProperty> lastOpenDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<UserStats, int?, QAfterProperty>
  selectedMushroomTypeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<UserStats, String?, QAfterProperty> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }
}

extension UserStatsQueryProperty2<R>
    on QueryBuilder<UserStats, R, QAfterProperty> {
  QueryBuilder<UserStats, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<UserStats, (R, int), QAfterProperty> totalCoinsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<UserStats, (R, int), QAfterProperty> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<UserStats, (R, int), QAfterProperty> longestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<UserStats, (R, DateTime?), QAfterProperty>
  lastSuccessDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<UserStats, (R, DateTime?), QAfterProperty>
  lastOpenDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<UserStats, (R, int?), QAfterProperty>
  selectedMushroomTypeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<UserStats, (R, String?), QAfterProperty> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }
}

extension UserStatsQueryProperty3<R1, R2>
    on QueryBuilder<UserStats, (R1, R2), QAfterProperty> {
  QueryBuilder<UserStats, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<UserStats, (R1, R2, int), QOperations> totalCoinsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<UserStats, (R1, R2, int), QOperations> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<UserStats, (R1, R2, int), QOperations> longestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<UserStats, (R1, R2, DateTime?), QOperations>
  lastSuccessDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<UserStats, (R1, R2, DateTime?), QOperations>
  lastOpenDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<UserStats, (R1, R2, int?), QOperations>
  selectedMushroomTypeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<UserStats, (R1, R2, String?), QOperations>
  displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }
}
