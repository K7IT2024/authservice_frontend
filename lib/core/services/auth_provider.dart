import 'package:flutter/material.dart';

import '../models/auth_user.dart';

class AuthProvider extends ChangeNotifier {

  AuthUser? currentUser;

  void setUser(AuthUser user){

    currentUser=user;

    notifyListeners();

  }

  void logout(){

    currentUser=null;

    notifyListeners();

  }

}