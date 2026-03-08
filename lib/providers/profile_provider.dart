import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final StorageService _storage;
  UserProfile _profile = UserProfile();

  ProfileProvider(this._storage);

  UserProfile get profile => _profile;

  Future<void> loadProfile() async {
    _profile = await _storage.loadProfile();
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? studyRoutine,
    String? specificNeeds,
  }) async {
    if (name != null) _profile.name = name;
    if (email != null) _profile.email = email;
    if (studyRoutine != null) _profile.studyRoutine = studyRoutine;
    if (specificNeeds != null) _profile.specificNeeds = specificNeeds;
    await _storage.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> importProfile(UserProfile profile) async {
    _profile = profile;
    await _storage.saveProfile(_profile);
    notifyListeners();
  }
}
