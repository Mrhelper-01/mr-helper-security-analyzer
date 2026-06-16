import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mr_helper_security_analyzer/models/scan_result.dart';
import 'package:mr_helper_security_analyzer/core/constants.dart';

/// MR HELPER - Web Application Security Analyzer
/// Service for Firebase Firestore CRUD operations

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _scansCollection =>
      _firestore.collection(AppConstants.scansCollection);

  /// Save a scan result to Firestore
  Future<void> saveScanResult(ScanResult result) async {
    try {
      await _scansCollection.add(result.toFirestore());
    } catch (e) {
      throw Exception('Failed to save scan result: $e');
    }
  }

  /// Get all scan results ordered by timestamp (newest first)
  Future<List<ScanResult>> getAllScans() async {
    try {
      final querySnapshot = await _scansCollection
          .orderBy(AppConstants.fieldTimestamp, descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => ScanResult.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch scan history: $e');
    }
  }

  /// Get scan results as a stream for real-time updates
  Stream<List<ScanResult>> getScansStream() {
    return _scansCollection
        .orderBy(AppConstants.fieldTimestamp, descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => ScanResult.fromFirestore(doc))
            .toList());
  }

  /// Get a single scan by document ID
  Future<ScanResult?> getScanById(String id) async {
    try {
      final doc = await _scansCollection.doc(id).get();
      if (doc.exists) {
        return ScanResult.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch scan: $e');
    }
  }

  /// Delete a scan by document ID
  Future<void> deleteScan(String id) async {
    try {
      await _scansCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete scan: $e');
    }
  }

  /// Delete multiple scans
  Future<void> deleteMultipleScans(List<String> ids) async {
    try {
      final batch = _firestore.batch();
      for (final id in ids) {
        batch.delete(_scansCollection.doc(id));
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete scans: $e');
    }
  }

  /// Get total number of scans
  Future<int> getTotalScans() async {
    try {
      final querySnapshot = await _scansCollection.get();
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get average security score
  Future<double> getAverageScore() async {
    try {
      final querySnapshot = await _scansCollection.get();
      if (querySnapshot.docs.isEmpty) return 0.0;

      final totalScore = querySnapshot.docs.fold<int>(
        0,
        // ignore: avoid_types_as_parameter_names
        (sum, doc) =>
            sum + ((doc.data() as Map<String, dynamic>)['score'] as int? ?? 0),
      );
      return totalScore / querySnapshot.docs.length;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get risk distribution
  Future<Map<String, int>> getRiskDistribution() async {
    try {
      final querySnapshot = await _scansCollection.get();
      final distribution = <String, int>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final risk = data['risk'] as String? ?? 'Unknown';
        distribution[risk] = (distribution[risk] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      return {};
    }
  }

  /// Get most scanned websites (top 5)
  Future<List<MapEntry<String, int>>> getMostScannedWebsites() async {
    try {
      final querySnapshot = await _scansCollection.get();
      final siteCount = <String, int>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final url = data['url'] as String? ?? '';
        // Extract hostname
        final hostname = Uri.tryParse(url)?.host ?? url;
        siteCount[hostname] = (siteCount[hostname] ?? 0) + 1;
      }

      final sorted = siteCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(5).toList();
    } catch (e) {
      return [];
    }
  }
}
