// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sudama_milk/screens/Home_screen.dart';
//
// import 'onboarding_screen.dart';
//
// class GoogleLoginScreen extends StatefulWidget {
//   const GoogleLoginScreen({super.key});
//
//   @override
//   State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
// }
//
// class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
//   bool _isSigningIn = false;
//
//   // 👇 Yaha apna Web client ID paste karo
//   static const String _serverClientId =
//       '100185279816-4h8akeluvph08vnjm2aduo9gjqmviaj8.apps.googleusercontent.com';
//
//   Future<void> _signInWithGoogle() async {
//     setState(() => _isSigningIn = true);
//
//     try {
//       // 1) GoogleSignIn v7 initialize with serverClientId
//       await GoogleSignIn.instance.initialize(
//         serverClientId: _serverClientId,
//       );
//
//       // 2) User se Google account select karvao
//       final GoogleSignInAccount? googleUser =
//       await GoogleSignIn.instance.authenticate();
//
//       if (googleUser == null) {
//         // user ne cancel kar diya
//         setState(() => _isSigningIn = false);
//         return;
//       }
//
//       // 3) Token lo
//       final GoogleSignInAuthentication googleAuth =
//       await googleUser.authentication;
//
//       // 4) Firebase credential (sirf idToken kaafi hai)
//       final credential = GoogleAuthProvider.credential(
//         idToken: googleAuth.idToken,
//       );
//
//       // 5) Firebase me sign-in
//       final userCredential =
//       await FirebaseAuth.instance.signInWithCredential(credential);
//
//       setState(() => _isSigningIn = false);
//
//       if (userCredential.user != null && mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const OnboardingScreen()),
//         );
//       }
//     } on GoogleSignInException catch (e) {
//       setState(() => _isSigningIn = false);
//       debugPrint('GoogleSignInException: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               'Google sign-in failed: ${e.code.toString()}'), // message nahi, code/toString use karo
//         ),
//       );
//     } catch (e) {
//       setState(() => _isSigningIn = false);
//       debugPrint('Google sign-in error: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Something went wrong: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Google Login')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.local_drink_rounded, size: 80),
//               const SizedBox(height: 16),
//               const Text(
//                 'Sudama Milk',
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Login with Google to continue',
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isSigningIn ? null : _signInWithGoogle,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isSigningIn
//                       ? const SizedBox(
//                     width: 22,
//                     height: 22,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                       : Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: const [
//                       Icon(Icons.g_mobiledata_rounded, size: 32),
//                       SizedBox(width: 8),
//                       Text(
//                         'Sign in with Google',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
