import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  void init() {
    final User user = FirebaseAuth.instance.currentUser;

    emit(ProfileLoading());

    if (user.displayName == '' || user.displayName == null) {
      Box userBox = Hive.box('user');
      String name = userBox.get('name');

      if (name != null) {
        emit(ProfileLoadedWithInfo(name));
        return;
      } else {
        emit(ProfileLoadedWithoutInfo());
        return;
      }
    } else {
      emit(ProfileLoadedWithGoogleInfo(user));

      return;
    }
  }

  Future<void> saveName(String name) async {
    Box userBox = Hive.box('user');

    await userBox.put('name', name);

    emit(ProfileLoadedWithInfo(name));
  }

  void enterEditingMode(String name) {
    emit(ProfileEditing(name));
  }
}
