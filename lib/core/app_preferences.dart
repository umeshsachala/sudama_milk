// import 'dart:convert';
//
// import 'package:marine_media_enterprises/screens/login/user_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AppPreferences {
//   static const String keyLoginUserDetails = "KEY_LOGIN_USER_DETAILS";
//   static const String keyAccessToken = "accessToken";
//   static const String isUserLogin = "userLogin";
//
//   Future<User?> getUserDetails() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     String loginDetails = prefs.getString(keyLoginUserDetails) ?? "";
//     try {
//       return User.fromJson(json.decode(loginDetails));
//     } catch (e) {
//       return null;
//     }
//   }
//
//   Future<bool> setUserDetails(String? value) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.setString(keyLoginUserDetails, value!);
//   }
//
//   Future<bool> removeUserDetails() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.remove(keyLoginUserDetails);
//   }
//
//   Future<String?> getAccessToken() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString(keyAccessToken);
//   }
//
//   Future<bool> setAccessToken(String token) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.setString(keyAccessToken, token);
//   }
//
//   Future<bool> setUserLogin(String? value) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.setString(isUserLogin, value!);
//   }
//
//   Future<String?> getUserLogin() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     String loginDetails = prefs.getString(isUserLogin) ?? "";
//     return loginDetails;
//   }
//
//   Future<bool> removeUserLogin() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.remove(isUserLogin);
//   }
// }
