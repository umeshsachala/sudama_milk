// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// import 'Home_screen.dart';
//
// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});
//
//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }
//
// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _controller = PageController();
//   int currentIndex = 0;
//   bool _isSigningIn = false;
//
//   // 👇 yahi Web client ID hai (Firebase -> Web SDK configuration)
//   static const String _serverClientId =
//       '100185279816-4h8akeluvph08vnjm2aduo9gjqmviaj8.apps.googleusercontent.com';
//
//   final List<Map<String, String>> onboardingData = [
//     {
//       "image": "assets/images/storeimage.png",
//       "title": "Welcome to Sudama Milk",
//       "desc": "Your digital partner for dairy management."
//     },
//     {
//       "image": "assets/images/storeimage.png",
//       "title": "Track Orders Easily",
//       "desc": "Record daily orders and monitor deliveries."
//     },
//     {
//       "image": "assets/images/storeimage.png",
//       "title": "Manage Stock Smartly",
//       "desc": "Keep full control over your milk & product stock."
//     },
//   ];
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
//       // 2) Google account chooser open karega
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
//       // 4) Firebase credential banao (sirf idToken)
//       final credential = GoogleAuthProvider.credential(
//         idToken: googleAuth.idToken,
//       );
//
//       // 5) Firebase me login
//       final userCredential =
//       await FirebaseAuth.instance.signInWithCredential(credential);
//
//       setState(() => _isSigningIn = false);
//
//       if (userCredential.user != null && mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const Homescreen()),
//         );
//       }
//     } on GoogleSignInException catch (e) {
//       setState(() => _isSigningIn = false);
//       debugPrint('GoogleSignInException: $e');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Google sign-in failed: ${e.code.toString()}'),
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
//   void _onGetStartedPressed() {
//     // yahi se direct google login call
//     _signInWithGoogle();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           /// Background Image
//           Positioned.fill(
//             child: Image.asset(
//               "assets/images/mil_bg.png",
//               fit: BoxFit.cover,
//               opacity: const AlwaysStoppedAnimation(0.25),
//             ),
//           ),
//
//           /// Gradient Overlay
//           Positioned.fill(
//             child: Container(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Color(0xFF6A11CB),
//                     Color(0xFF2575FC),
//                   ],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   stops: [0.1, 1],
//                 ),
//               ),
//             ),
//           ),
//
//           /// Main Content
//           Column(
//             children: [
//               Expanded(
//                 child: PageView.builder(
//                   controller: _controller,
//                   itemCount: onboardingData.length,
//                   onPageChanged: (index) =>
//                       setState(() => currentIndex = index),
//                   itemBuilder: (context, index) {
//                     return buildPage(
//                       onboardingData[index]["image"]!,
//                       onboardingData[index]["title"]!,
//                       onboardingData[index]["desc"]!,
//                     );
//                   },
//                 ),
//               ),
//
//               /// Page Indicators
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   onboardingData.length,
//                       (index) => buildIndicator(index == currentIndex),
//                 ),
//               ),
//               const SizedBox(height: 25),
//
//               /// Next / Get Started Button
//               Padding(
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       elevation: 5,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     onPressed: _isSigningIn
//                         ? null
//                         : () {
//                       if (currentIndex ==
//                           onboardingData.length - 1) {
//                         // last page -> direct Google login
//                         _onGetStartedPressed();
//                       } else {
//                         _controller.nextPage(
//                           duration:
//                           const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                         );
//                       }
//                     },
//                     child: _isSigningIn
//                         ? const SizedBox(
//                       width: 22,
//                       height: 22,
//                       child:
//                       CircularProgressIndicator(strokeWidth: 2),
//                     )
//                         : Text(
//                       currentIndex == onboardingData.length - 1
//                           ? "Get Started"
//                           : "Next",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         color: Color(0xFF6A11CB),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Page Design
//   Widget buildPage(String img, String title, String desc) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 25),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           /// Glassmorphic Card
//           Container(
//             padding: const EdgeInsets.all(25),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: Colors.white30),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.white.withOpacity(0.2),
//                   blurRadius: 20,
//                   spreadRadius: 2,
//                 )
//               ],
//             ),
//             child: Image.asset(img, width: 200),
//           ),
//
//           const SizedBox(height: 40),
//
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 28,
//               fontWeight: FontWeight.w800,
//               color: Colors.white,
//               letterSpacing: 1,
//             ),
//           ),
//
//           const SizedBox(height: 15),
//
//           Text(
//             desc,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.white.withOpacity(0.9),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Indicator
//   Widget buildIndicator(bool active) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       height: 10,
//       width: active ? 28 : 10,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: active ? Colors.white : Colors.white54,
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'Home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;
  bool _isSigningIn = false;

  static const String _serverClientId =
      '100185279816-4h8akeluvph08vnjm2aduo9gjqmviaj8.apps.googleusercontent.com';

  /// 🔹 BACKGROUND BASED DATA
  final List<Map<String, String>> onboardingData = [
    {
      "bg": "assets/images/milk_bg.png",
      "title": "Fresh Milk, Every Morning",
      "desc": "Pure and hygienic milk delivered daily."
    },
    {
      "bg": "assets/images/paneer_bg.png",
      "title": "Soft & Pure Paneer",
      "desc": "High-quality paneer for hotels & homes."
    },
    {
      "bg": "assets/images/ghee_bg.png",
      "title": "Pure Desi Ghee",
      "desc": "Traditional taste with rich aroma."
    },
  ];

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);

    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: _serverClientId,
      );

      final GoogleSignInAccount? googleUser =
      await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        setState(() => _isSigningIn = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      setState(() => _isSigningIn = false);

      if (userCredential.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Homescreen()),
        );
      }
    } catch (e) {
      setState(() => _isSigningIn = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: onboardingData.length,
        onPageChanged: (i) => setState(() => currentIndex = i),
        itemBuilder: (context, index) {
          final item = onboardingData[index];

          return Stack(
            fit: StackFit.expand,
            children: [
              /// 🔹 FULL BACKGROUND IMAGE
              Image.asset(
                item["bg"]!,
                fit: BoxFit.cover,
              ),

              /// 🔹 DARK OVERLAY
              Container(
                color: Colors.black.withOpacity(0.45),
              ),

              /// 🔹 CONTENT
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        Text(
                          item["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item["desc"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// DOTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                          (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.all(4),
                        width: currentIndex == i ? 26 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: currentIndex == i
                              ? Colors.white
                              : Colors.white54,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// BUTTON
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 25),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSigningIn
                            ? null
                            : () {
                          if (currentIndex ==
                              onboardingData.length - 1) {
                            _signInWithGoogle();
                          } else {
                            _controller.nextPage(
                              duration:
                              const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: _isSigningIn
                            ? const CircularProgressIndicator(
                          strokeWidth: 2,
                        )
                            : Text(
                          currentIndex ==
                              onboardingData.length - 1
                              ? "Get Started"
                              : "Next",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF6A11CB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
