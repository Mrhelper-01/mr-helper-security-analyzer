import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mr_helper_security_analyzer/models/scan_result.dart';
import 'package:mr_helper_security_analyzer/services/firestore_service.dart';
import 'package:mr_helper_security_analyzer/services/security_scanner_service.dart';

/// MR HELPER - Web Application Security Analyzer
/// Provider for scan operations, history, and statistics

class ScanProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final SecurityScannerService _scannerService = SecurityScannerService();

  // Scan state
  bool _isScanning = false;
  String? _scanError;
  ScanResult? _latestScanResult;

  // History state
  List<ScanResult> _scanHistory = [];
  bool _isLoadingHistory = false;
  String? _historyError;

  // Statistics state
  int _totalScans = 0;
  double _averageScore = 0.0;
  Map<String, int> _riskDistribution = {};
  List<MapEntry<String, int>> _mostScannedWebsites = [];
  bool _isLoadingStats = false;

  // Sort order
  bool _sortAscending = false;

  // Getters
  bool get isScanning => _isScanning;
  String? get scanError => _scanError;
  ScanResult? get latestScanResult => _latestScanResult;
  List<ScanResult> get scanHistory => _scanHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyError => _historyError;
  int get totalScans => _totalScans;
  double get averageScore => _averageScore;
  Map<String, int> get riskDistribution => _riskDistribution;
  List<MapEntry<String, int>> get mostScannedWebsites => _mostScannedWebsites;
  bool get isLoadingStats => _isLoadingStats;
  bool get sortAscending => _sortAscending;

  /// Perform a security scan on the given URL
  Future<ScanResult?> scanUrl(String url) async {
    _isScanning = true;
    _scanError = null;
    _latestScanResult = null;
    notifyListeners();

    try {
      final result = await _scannerService.performScan(url);
      
      // Save to Firestore
      await _firestoreService.saveScanResult(result);
      
      _latestScanResult = result;
      _isScanning = false;
      notifyListeners();
      
      // Refresh history
      loadScanHistory();
      
      return result;
    } catch (e) {
      _scanError = e.toString().replaceAll('Exception: ', '');
      _isScanning = false;
      notifyListeners();
      return null;
    }
  }

  /// Load scan history from Firestore
  Future<void> loadScanHistory() async {
    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    try {
      _scanHistory = await _firestoreService.getAllScans();
      _applySort();
      _isLoadingHistory = false;
      notifyListeners();
    } catch (e) {
      _historyError = e.toString().replaceAll('Exception: ', '');
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Delete a scan from history
  Future<void> deleteScan(String id) async {
    try {
      await _firestoreService.deleteScan(id);
      _scanHistory.removeWhere((scan) => scan.id == id);
      notifyListeners();
      
      // Refresh stats
      loadStatistics();
    } catch (e) {
      throw Exception('Failed to delete scan: ${e.toString()}');
    }
  }

  /// Toggle sort order
  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    _applySort();
    notifyListeners();
  }

  /// Apply current sort order to history
  void _applySort() {
    if (_sortAscending) {
      _scanHistory.sort((a, b) {
        final aTime = a.timestamp ?? DateTime(2000);
        final bTime = b.timestamp ?? DateTime(2000);
        return aTime.compareTo(bTime);
      });
    } else {
      _scanHistory.sort((a, b) {
        final aTime = a.timestamp ?? DateTime(2000);
        final bTime = b.timestamp ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
    }
  }

  /// Load statistics from Firestore
  Future<void> loadStatistics() async {
    _isLoadingStats = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _firestoreService.getTotalScans(),
        _firestoreService.getAverageScore(),
        _firestoreService.getRiskDistribution(),
        _firestoreService.getMostScannedWebsites(),
      ]);

      _totalScans = results[0] as int;
      _averageScore = results[1] as double;
      _riskDistribution = results[2] as Map<String, int>;
      _mostScannedWebsites = results[3] as List<MapEntry<String, int>>;

      _isLoadingStats = false;
      notifyListeners();
    } catch (e) {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  /// Clear scan error
  void clearError() {
    _scanError = null;
    notifyListeners();
  }
}
