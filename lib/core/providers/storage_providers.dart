import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:resky/core/failure.dart';
import 'package:resky/core/providers/firebase_providers.dart';
import 'package:resky/core/type_defs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final storageRepositoryProvider = Provider(
  (ref) => StorageRepository(
    supabaseStorage: ref.watch(supabaseStorageProvider),
  ),
);

class StorageRepository {
  final SupabaseStorageClient _supabaseStorage;
  StorageRepository({required SupabaseStorageClient supabaseStorage})
      : _supabaseStorage = supabaseStorage;

  FutureEither<String> storeFile({
    required String path,
    required String id,
    required File? file,
  }) async {
    try {
      if (file == null) {
        throw Exception("File cannot be null");
      }

      final fileName = id;

      // Read file bytes
      final fileBytes = await file.readAsBytes();

      // Upload the file using Supabase's storage API
      final response = await _supabaseStorage.from(path).uploadBinary(fileName, fileBytes);

      // Check for upload errors
      if (response == null) {
        throw Exception("Failed to upload file");
      }

      // Get the public URL of the uploaded file
      final publicUrl = _supabaseStorage.from(path).getPublicUrl(fileName);
      return right(publicUrl);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
