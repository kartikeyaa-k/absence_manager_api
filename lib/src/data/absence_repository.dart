import 'dart:convert';
import 'dart:io';

/// A repository for reading and combining absences and member data
/// from JSON files.
///
/// Absence data is read from `absencesPath` and member data from
/// `membersPath`. The repository can apply pagination and enrich
/// each absence record with its corresponding member’s name and image.

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
    final rawList = (wrapper['payload'] as List).cast<Map<String, dynamic>>();
    return {
      for (final m in rawList) m['userId'] as int: m,
    };
  }

  /// Returns a paginated, member‑enriched set of absences.
  /// If [userId] is provided, filters to that user only (no pagination on filtered set).
  Future<Map<String, dynamic>> fetchPaginatedEnriched({
    required int page,
    required int limit,
    int? userId,
  }) async {
    var all = await _loadAbsences();
    final members = await _loadMembersMap();

    // Optional filter by userId
    if (userId != null) {
      all = all.where((a) => a['userId'] == userId).toList();
    }

    final total = all.length;

    // If userId filter is present, return all results without paging:
    final slice = (userId != null)
        ? all
        : ((page - 1) * limit < total
            ? all.sublist(
                (page - 1) * limit,
                ((page - 1) * limit + limit).clamp(0, total),
              )
            : <Map<String, dynamic>>[]);

    final data = slice.map((abs) {
      final member = members[abs['userId']] ?? {};
      return {
        ...abs,
        'memberName': member['name'] ?? 'Unknown',
        'memberImage': member['image'],
      };
    }).toList();

    return {
      'total': total,
      if (userId == null) 'page': page,
      if (userId == null) 'limit': limit,
      'data': data,
    };
  }
}
