import 'dart:convert';
import 'dart:io';

/// A repository for reading and combining absences and member data
/// from JSON files.
///
/// Absence data is read from [absencesPath] and member data from [membersPath].
/// The repository supports:
/// - Pagination
/// - Filtering by userId, type, and date range
/// - Enriching absence records with member name & image
///
/// ### Future Improvements:
/// - Sort by startDate or createdAt
/// - Add caching or debounce for file reads
/// - Move to a database-backed repository for scalability
class AbsenceRepository {
  /// Creates a repository that reads from the given file paths.

  AbsenceRepository({
    this.absencesPath = 'data/absences.json',
    this.membersPath = 'data/members.json',
  });

  /// Path to the absences JSON file.
  final String absencesPath;

  /// Path to the members JSON file.
  final String membersPath;

  Future<List<Map<String, dynamic>>> _loadAbsences() async {
    final content = await File(absencesPath).readAsString();
    final wrapper = jsonDecode(content) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(wrapper['payload'] as List);
  }

  Future<Map<int, Map<String, dynamic>>> _loadMembersMap() async {
    final content = await File(membersPath).readAsString();
    final wrapper = jsonDecode(content) as Map<String, dynamic>;
    final rawList = List<Map<String, dynamic>>.from(wrapper['payload'] as List);
    return {
      for (final m in rawList) m['userId'] as int: m,
    };
  }

  /// Returns a paginated and enriched list of absences.
  ///
  /// Filters:
  /// - [userId]: Filter by user
  /// - [type]: Filter by absence type (e.g. vacation)
  /// - [startDate], [endDate]: Filter absences overlapping this date range
  ///
  /// Pagination:
  /// - [page] and [limit] always apply
  Future<Map<String, dynamic>> fetchPaginatedEnriched({
    required int page,
    required int limit,
    int? userId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allAbsences = await _loadAbsences();
    final members = await _loadMembersMap();

    var filtered = allAbsences;
    filtered = _filterByUser(filtered, userId);
    filtered = _filterByType(filtered, type);
    filtered = _filterByDateRange(filtered, startDate, endDate)
      ..sort((a, b) {
        final aDate = DateTime.tryParse(a['startDate'] as String? ?? '');
        final bDate = DateTime.tryParse(b['startDate'] as String? ?? '');
        if (aDate == null || bDate == null) return 0;
        return aDate.compareTo(bDate);
      });

    final total = filtered.length;
    final paginated = _applyPagination(filtered, page, limit);

    final enriched = paginated.map((absence) {
      final member = members[absence['userId']] ?? {};
      return {
        ...absence,
        'memberName': member['name'] ?? 'Unknown',
        'memberImage': member['image'],
      };
    }).toList();

    return {
      'total': total,
      'page': page,
      'limit': limit,
      'data': enriched,
    };
  }

  /// Filters absences by userId if provided.
  List<Map<String, dynamic>> _filterByUser(
    List<Map<String, dynamic>> absences,
    int? userId,
  ) {
    if (userId == null) return absences;
    return absences.where((a) => a['userId'] == userId).toList();
  }

  /// Filters absences by type (e.g., vacation, sickness) if provided.
  List<Map<String, dynamic>> _filterByType(
    List<Map<String, dynamic>> absences,
    String? type,
  ) {
    if (type == null || type.isEmpty) return absences;
    return absences.where((a) => a['type'] == type).toList();
  }

  /// Filters absences that overlap with the provided date range.
  List<Map<String, dynamic>> _filterByDateRange(
    List<Map<String, dynamic>> absences,
    DateTime? start,
    DateTime? end,
  ) {
    if (start == null || end == null) return absences;

    return absences.where((a) {
      final aStart =
          a['startDate'] != null && a['startDate'].toString().isNotEmpty
              ? DateTime.tryParse(a['startDate'].toString())
              : null;
      final aEnd = a['endDate'] != null && a['endDate'].toString().isNotEmpty
          ? DateTime.tryParse(a['endDate'].toString())
          : null;
      if (aStart == null || aEnd == null) return false;
      return !(aEnd.isBefore(start) || aStart.isAfter(end));
    }).toList();
  }

  /// Returns the paginated subset of [absences] based on [page] and [limit].
  List<Map<String, dynamic>> _applyPagination(
    List<Map<String, dynamic>> absences,
    int page,
    int limit,
  ) {
    final start = (page - 1) * limit;
    final end = (start + limit).clamp(0, absences.length);
    if (start >= absences.length) return [];
    return absences.sublist(start, end);
  }
}
