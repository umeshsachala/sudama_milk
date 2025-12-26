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

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/Image_1.png",
      "title": "Smart Stock Management",
      "desc":
      "Manage all your shop items digitally. Add products, update quantity and check stock anytime."
    },
    {
      "image": "assets/images/Image_2.png",
      "title": "Easy Stock In & Out",
      "desc":
      "Record daily stock in and stock out entries clearly and avoid manual mistakes."
    },
    {
      "image": "assets/images/Image_3.png",
      "title": "Built for Shop Owners",
      "desc":
      "Control your goods, view history, and manage daily stock movement with ease."
    },
  ];

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: _serverClientId,
      );

      final user = await GoogleSignIn.instance.authenticate();
      if (user == null) {
        setState(() => _isSigningIn = false);
        return;
      }

      final auth = await user.authentication;
      final cred = GoogleAuthProvider.credential(idToken: auth.idToken);
      await FirebaseAuth.instance.signInWithCredential(cred);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Homescreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login failed")));
    }
    setState(() => _isSigningIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 PAGE VIEW
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (i) => setState(() => currentIndex = i),
            itemBuilder: (context, index) {
              final item = onboardingData[index];
              final imagePath = item["image"];

              return Stack(
                fit: StackFit.expand,
                children: [
                  /// ✅ SAFE IMAGE LOAD
                  if (imagePath != null)
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey.shade200),
                    )
                  else
                    Container(color: Colors.grey.shade200),

                  /// LIGHT OVERLAY
                  Container(
                    color: Colors.white.withOpacity(0.65),
                  ),

                  /// CONTENT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item["title"] ?? "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item["desc"] ?? "",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          /// 🔹 DOTS + BUTTON (BOTTOM FIXED)
          Positioned(
            left: 0,
            right: 0,
            bottom: 35,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                        (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.all(4),
                      width: currentIndex == i ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentIndex == i
                            ? Colors.indigo
                            : Colors.indigo.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
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
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                          : Text(
                        currentIndex ==
                            onboardingData.length - 1
                            ? "Login with Google"
                            : "Next",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
