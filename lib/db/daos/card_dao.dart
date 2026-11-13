import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'card_dao.g.dart';

@DriftAccessor(tables: [CardCache])
class CardDao extends DatabaseAccessor<AppDatabase> with _$CardDaoMixin {
  CardDao(super.db);

  /// Check if the cache is empty
  Future<bool> isCacheEmpty() async {
    // Use limit(1) to check existence without scanning the full table
    final query = selectOnly(cardCache)
      ..addColumns([cardCache.factId])
      ..limit(1);
    final result = await query.get();
    return result.isEmpty;
  }

  /// Clear the entire cache
  Future<void> clearCache() async {
    await delete(cardCache).go();
  }

  /// Insert or update a card in the cache
  Future<void> upsertCard(CardCacheCompanion card) async {
    await into(cardCache).insertOnConflictUpdate(card);
  }

  /// Delete a card from cache by factId
  Future<void> deleteCard(String factId) async {
    await (delete(cardCache)..where((tbl) => tbl.factId.equals(factId))).go();
  }

  /// Query cards with filters and pagination
  Future<List<CardCacheData>> getCards({
    int page = 1,
    int limit = 20,
    List<String>? tags,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final query = select(cardCache);

    // Date Filters
    if (dateFrom != null) {
      final fromTs = DateTime(dateFrom.year, dateFrom.month, dateFrom.day)
              .millisecondsSinceEpoch ~/
          1000;
      query.where((tbl) => tbl.timestamp.isBiggerOrEqualValue(fromTs));
    }
    if (dateTo != null) {
      // End of dateTo's civil day. A 24-hour add drops the last hour when
      // clocks fall back.
      final toDate = DateTime(dateTo.year, dateTo.month, dateTo.day + 1)
          .subtract(const Duration(seconds: 1));
      final toTs = toDate.millisecondsSinceEpoch ~/ 1000;
      query.where((tbl) => tbl.timestamp.isSmallerOrEqualValue(toTs));
    }

    // Tag Filters (JSON list string 'contains' logic via LIKE)
    if (tags != null && tags.isNotEmpty) {
      final tagConditions = tags.map((t) => cardCache.tags.like('%"$t"%'));
      var combinedCondition = tagConditions.first;
      for (var i = 1; i < tagConditions.length; i++) {
        combinedCondition = combinedCondition | tagConditions.elementAt(i);
      }
      query.where((tbl) => combinedCondition);
    }

    // Sorting: Timestamp DESC, then FactId DESC
    query.orderBy([
      (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.factId, mode: OrderingMode.desc)
    ]);

    // Pagination
    final offset = (page - 1) * limit;
    query.limit(limit, offset: offset);

    return await query.get();
  }
}
