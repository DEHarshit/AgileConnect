import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:routemaster/routemaster.dart';
import 'package:resky/controller/auth_controller.dart';
import 'package:resky/core/constants/constants.dart';
import 'package:resky/core/failure.dart';
import 'package:resky/core/providers/storage_providers.dart';
import 'package:resky/models/community.dart';
import 'package:resky/models/post_model.dart';
import 'package:resky/services/community_repository.dart';
import 'package:resky/core/utils.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserDepartments();
});

final communitiesProvider = StreamProvider((ref) {
  final communityController = ref.read(communityControllerProvider.notifier);
  return communityController.getDepartments();
});

final communitiesChildrenProvider = StreamProvider.family((ref,String name) {
  final communityChildrenController = ref.read(communityControllerProvider.notifier);
  return communityChildrenController.getDepartmentsChildren(name);
});

final getCommunityPostsProvider = StreamProvider.family((ref, String name) {
  return ref.read(communityControllerProvider.notifier).getCommunityPosts(name);
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityController(
    communityRepository: communityRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController(
      {required CommunityRepository communityRepository,
      required Ref ref,
      required storageRepository})
      : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name,Community selectedCommunity, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? ''; //read user uid
    Community community = Community(
      id: name,
      name: name.replaceAll(RegExp(r"\s+"), "").toLowerCase(),
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
      parent: selectedCommunity.name,
      topParent: selectedCommunity.name == "root" ? name.replaceAll(RegExp(r"\s+"), "").toLowerCase() : selectedCommunity.topParent,
      children: [] 
    );

    if(selectedCommunity.name != "root"){
      _communityRepository.updateChildren(selectedCommunity, name);
    }
    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Department created successfully!');
      Routemaster.of(context).pop();
    });
  }


  void joinDepartment(Community department, BuildContext context) async {
    final user = _ref.read(userProvider)!;

    Either<Failure, void> res;

    if (department.members.contains(user.uid)) {
      res =
          await _communityRepository.leaveDepartment(department.name, user.uid);
    } else {
      res =
          await _communityRepository.joinDepartment(department.name, user.uid);
    }
    res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => {
              if (department.members.contains(user.uid))
                {showSnackBar(context, 'Department left successfully!')}
              else
                {showSnackBar(context, 'Department joined successfully!')}
            });
  }

  Stream<List<Community>> getUserDepartments() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserDepartments(uid);
  }

  Stream<List<Community>> getDepartments() {
    return _communityRepository.getDepartments();
  }

  Stream<List<Community>> getDepartmentsChildren(String name) {
    return _communityRepository.getDepartmentsChildren(name);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editDepartment({
    required File? avatarFile,
    required File? bannerFile,
    required BuildContext context,
    required Community department,
  }) async {
    state = true;
    if (avatarFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'departments/avatar',
        id: department.name,
        file: avatarFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => department = department.copyWith(avatar: r),
      );
    }

    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'departments/banner',
        id: department.name,
        file: bannerFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => department = department.copyWith(banner: r),
      );
    }

    final res = await _communityRepository.editDepartment(department);
    state = false;
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void addMods(
      String departmentName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(departmentName, uids);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _communityRepository.getCommunityPosts(name);
  }

}