import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:audioplayers/audioplayers.dart';

import 'kategori_user.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KringPosApp());
}

class KringPosApp extends StatelessWidget {
  const KringPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'KringPos',
      debugShowCheckedModeBanner: false,
      home: LogoScreen(),
    );
  }
}

class LogoScreen extends StatefulWidget {
  const LogoScreen({super.key});

  @override
  State<LogoScreen> createState() => _LogoScreenState();
}

class _LogoScreenState extends State<LogoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Animasi fade-in
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // Mainkan suara dan lanjut ke halaman berikutnya setelah delay
    _playSoundAndNavigate();
  }

  Future<void> _playSoundAndNavigate() async {
    await _audioPlayer.play(AssetSource('ringbell.mp3'));
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const KategoriUser()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final left = screenWidth * 0.25;
    final top = screenHeight * 0.4;
    final logoWidth = screenWidth * 0.5;
    final logoHeight = logoWidth * 0.9;

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _animation,
        child: Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: Image.asset(
                'assets/logo.png',
                width: logoWidth,
                height: logoHeight,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
