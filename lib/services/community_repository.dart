import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:resky/core/constants/firebase_constants.dart';
import 'package:resky/core/failure.dart';
import 'package:resky/core/providers/firebase_providers.dart';
import 'package:resky/core/type_defs.dart';
import 'package:resky/models/community.dart';
import 'package:resky/models/post_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _departments.doc(community.name).get();
      if (communityDoc.exists) {
        throw 'Department already exists!';
      }
      return right(_departments.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinDepartment(String departmentName, String uid) async {
    try {
      return right(_departments.doc(departmentName).update({
        'members': FieldValue.arrayUnion([uid]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveDepartment(String departmentName, String uid) async {
    try {
      return right(_departments.doc(departmentName).update({
        'members': FieldValue.arrayRemove([uid]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserDepartments(String uid) {
    return _departments
        .where('members', arrayContains: uid,)
        .where('parent', isEqualTo: "root")
        .snapshots()
        .map((event) {
      List<Community> departments = [];
      for (var doc in event.docs) {
        departments.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return departments;
    });
  }

  Stream<List<Community>> getDepartments() {
    return _departments.snapshots().map((event) {
      List<Community> departments = [];
      for (var doc in event.docs) {
        departments.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return departments;
    });
  }

  Stream<List<Community>> getDepartmentsChildren(String name) {
  return _departments.where('parent', isEqualTo: name).snapshots().map((querySnapshot) {
    return querySnapshot.docs.map((doc) => Community.fromMap(doc.data() as Map<String, dynamic>)).toList();
  });
}

  Stream<Community> getCommunityByName(String name) {
    return _departments.doc(name).snapshots().map(
        (event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }

  //edit department

  FutureVoid editDepartment(Community department) async {
    try {
      return right(
          _departments.doc(department.name).update(department.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //Search Button

  Stream<List<Community>> searchCommunity(String query) {
    query = query.replaceAll(RegExp(r"\s+"), "").toLowerCase();
    return _departments
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((event) {
      List<Community> departments = [];
      for (var department in event.docs) {
        departments
            .add(Community.fromMap(department.data() as Map<String, dynamic>));
      }
      return departments;
    });
  }

  //save mods

  FutureVoid addMods(String departmentName, List<String> uids) async {
    try {
      return right(_departments.doc(departmentName).update({
        'mods': uids,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  CollectionReference get _departments =>
      _firestore.collection(FirebaseConstants.departmentsCollection);

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  Stream<List<Post>> getCommunityPosts(String name) {
    return _posts
        .where('communityName', isEqualTo: name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }
/* 
  FutureVoid updateCommunity(Community community, String category) async {
    try {
      await _departments.doc(community.name).update({
        'subjects': FieldValue.arrayUnion([category]),
      });
      return right(null);
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  } */

  void updateChildren(Community community, String id) {
    _departments.doc(community.name).update({
      'children': FieldValue.arrayUnion([id]),
    });
  }
}
