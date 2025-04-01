import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:resky/core/constants/firebase_constants.dart';
import 'package:resky/core/failure.dart';
import 'package:resky/core/providers/firebase_providers.dart';
import 'package:resky/core/type_defs.dart';
import 'package:resky/models/community.dart';
import 'package:resky/models/post_model.dart';
import 'package:resky/models/report_model.dart';

final reportRepositoryProvider = Provider((ref) {
  return ReportRepository(firestore: ref.watch(firestoreProvider));
});

class ReportRepository {
  final FirebaseFirestore _firestore;
  ReportRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _reports =>
      _firestore.collection(FirebaseConstants.reportsCollection);

  FutureVoid addReport(Report report) async {
    try {
      return right(_reports.doc(report.id).set(report.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateReport(String id) async {
    try {
      return right(_reports.doc(id).update({
        'reportCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Report>> getCommunityReports(String name) {
    return _reports
        .where('communityName', isEqualTo: name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Report.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  FutureVoid deleteReport(Report report) async {
    try {
      return right(_reports.doc(report.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<Report> getReportsById(String reportId) {
    return _reports
        .doc(reportId)
        .snapshots()
        .map((event) => Report.fromMap(event.data() as Map<String, dynamic>));
  }

  Stream<List<Report>> getReportsByPostId(String postId) {
    return _reports
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Report.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

}
