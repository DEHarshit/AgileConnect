import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:resky/controller/auth_controller.dart';
import 'package:resky/core/providers/storage_providers.dart';
import 'package:resky/core/utils.dart';
import 'package:resky/models/community.dart';
import 'package:resky/models/post_model.dart';
import 'package:resky/models/report_model.dart';
import 'package:resky/services/reports_repository.dart';
import 'package:uuid/uuid.dart';

final reportControllerProvider =
    StateNotifierProvider<ReportController, bool>((ref) {
  final reportRepository = ref.watch(reportRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return ReportController(
    reportRepository: reportRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getReportByIdProvider = StreamProvider.family((ref, String reportId) {
  final reportController = ref.watch(reportControllerProvider.notifier);
  return reportController.getReportById(reportId);
});

final getReportsByPostIdProvider = StreamProvider.family<List<Report>, String>((ref, postId) {
  final reportController = ref.watch(reportControllerProvider.notifier);
  return reportController.getReportsByPostId(postId);
});

final getCommunityReportsProvider = StreamProvider.family((ref, String name) {
  return ref.read(reportControllerProvider.notifier).getCommunityReports(name);
});

class ReportController extends StateNotifier<bool> {
  final ReportRepository _reportRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  ReportController(
      {required ReportRepository reportRepository,
      required Ref ref,
      required storageRepository})
      : _reportRepository = reportRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  //text

  void shareReport({
    required BuildContext context,
    required String text,
    required String communityName,
    required String postId,
    required String type,
  }) async {
    state = true;
    String reportId = const Uuid().v1();
    List<String> textList = [text];
    final communityReportsStream = getCommunityReports(communityName);

    communityReportsStream.first.then((communityReports) async {
      Report? existingReport;
      try {
        existingReport = communityReports.firstWhere((report) => report.postId == postId);
      } catch (e) {
        existingReport = null;
      }

      if (existingReport != null) {
        existingReport.text.add(text);
        final res = await _reportRepository.addReport(existingReport);
        state = false;
        res.fold((l) => showSnackBar(context, l.message), (r) {
          showSnackBar(context, 'Reported successfully!');
        });
      } else {
        final Report newReport = Report(
          id: reportId,
          text: textList,
          communityName: communityName,
          postId: postId,
          type: type,
          createdAt: DateTime.now(),
          reportCount: 1,
        );

        final res = await _reportRepository.addReport(newReport);
        state = false;
        res.fold((l) => showSnackBar(context, l.message), (r) {
          showSnackBar(context, 'Reported successfully!');
        });
      }
    });
  }

 void deleteModReport(String postId, BuildContext context) async {
  final reportStream = _ref.read(getReportsByPostIdProvider(postId).stream);

  reportStream.first.then((reports) async {
    if (reports.isNotEmpty) {
      for (var report in reports) {
        final res = await _reportRepository.deleteReport(report);
        res.fold(
          (l) => showSnackBar(context, 'Error deleting report: ${l.message}'),
          (r) => showSnackBar(context, 'Report Deleted Successfully'),
        );
      }
    }
  }).catchError((e) {
    showSnackBar(context, 'Error: $e');
  });
}


  void deleteReport(Report report, BuildContext context) async {
    final res = await _reportRepository.deleteReport(report);
    res.fold((l) => null, (r) => showSnackBar(context, 'Report Resolved!'));
  }

  Stream<Report> getReportById(String reportId) {
    return _reportRepository.getReportsById(reportId);
  }

  Stream<List<Report>> getReportsByPostId(String reportId) {
    return _reportRepository.getReportsByPostId(reportId);
  }


  Stream<List<Report>> getCommunityReports(String name) {
    return _reportRepository.getCommunityReports(name);
  }
}
