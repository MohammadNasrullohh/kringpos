import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

import 'favorit_page.dart';
import 'face_detection_page.dart'; // ← Tambahkan ini

class ProfilePage extends StatefulWidget {
  final String usernameFromDatabase;
  final String roleFromDatabase;
  final String emailFromDatabase;

  const ProfilePage({
    super.key,
    required this.usernameFromDatabase,
    required this.roleFromDatabase,
    required this.emailFromDatabase,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showDropdown = false;
  File? _profileImage;

  final _database = FirebaseDatabase.instance.ref();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.usernameFromDatabase);
    _emailController = TextEditingController(text: widget.emailFromDatabase);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.emailFromDatabase.isEmpty) {
      fetchEmailByUsername(widget.usernameFromDatabase);
    }
  }

  Future<void> fetchEmailByUsername(String username) async {
    try {
      final snapshot = await _database
          .child('users')
          .orderByChild('username')
          .equalTo(username)
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final firstUser = data.values.first as Map;
        final fetchedEmail = firstUser['email'] ?? '';
        setState(() {
          _emailController.text = fetchedEmail;
        });
      }
    } catch (e) {
      debugPrint('Gagal mengambil email: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _showDropdown = !_showDropdown;
      if (_showDropdown) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _getImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final File? filteredImage = await Navigator.push<File?>(
        context,
        MaterialPageRoute(builder: (context) => const FaceDetectionPage()),
      );

      if (filteredImage != null) {
        setState(() {
          _profileImage = filteredImage;
        });
      }
    } else {
      final pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    }
    _toggleDropdown();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    String? roleImage;
    if (widget.roleFromDatabase.toLowerCase() == 'admin') {
      roleImage = 'assets/roleowner.png';
    } else if (widget.roleFromDatabase.toLowerCase() == 'user') {
      roleImage = 'assets/rolekasir.png';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: Image.asset('assets/right.png', width: 25, height: 25),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritPage()),
                );
              },
            ),
          ),
          Positioned(
            top: 50,
            left: (screenWidth - 100) / 2,
            child: GestureDetector(
              onTap: _toggleDropdown,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!) as ImageProvider
                    : const AssetImage('assets/profilebesar.png'),
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _toggleDropdown,
                child: const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0095FF),
                    fontFamily: 'PoppinsMedium',
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 191,
            left: 20,
            right: 20,
            child: const Divider(color: Colors.black, thickness: 0.5),
          ),
          const Positioned(
            top: 206,
            left: 67,
            child: Text(
              'Nama',
              style: TextStyle(fontSize: 12, color: Color(0xFF888888), fontFamily: 'Poppins'),
            ),
          ),
          const Positioned(
            top: 214,
            left: 28,
            child: Image(
              image: AssetImage('assets/editname.png'),
              width: 24,
              height: 24,
            ),
          ),
          Positioned(
            top: 225,
            left: 67,
            right: 20,
            child: TextField(
              controller: _usernameController,
              style: const TextStyle(fontSize: 12, color: Colors.black, fontFamily: 'PoppinsMedium'),
              decoration: const InputDecoration(isDense: true, border: InputBorder.none),
            ),
          ),
          const Positioned(
            top: 274,
            left: 67,
            child: Text(
              'Role User',
              style: TextStyle(fontSize: 12, color: Color(0xFF888888), fontFamily: 'Poppins'),
            ),
          ),
          const Positioned(
            top: 287,
            left: 27,
            child: Image(
              image: AssetImage('assets/role.png'),
              width: 24,
              height: 24,
            ),
          ),
          Positioned(
            top: 295,
            left: 67,
            child: Row(
              children: [
                Text(
                  widget.roleFromDatabase,
                  style: const TextStyle(fontSize: 12, color: Colors.black, fontFamily: 'PoppinsMedium'),
                ),
                const SizedBox(width: 6),
                if (roleImage != null)
                  Image.asset(
                    roleImage,
                    width: 44,
                    height: 15,
                  ),
              ],
            ),
          ),
          const Positioned(
            top: 343,
            left: 67,
            child: Text(
              'Email',
              style: TextStyle(fontSize: 12, color: Color(0xFF888888), fontFamily: 'Poppins'),
            ),
          ),
          const Positioned(
            top: 355,
            left: 27,
            child: Image(
              image: AssetImage('assets/email.png'),
              width: 24,
              height: 24,
            ),
          ),
          Positioned(
            top: 365,
            left: 67,
            right: 20,
            child: TextField(
              controller: _emailController,
              style: const TextStyle(fontSize: 12, color: Colors.black, fontFamily: 'PoppinsMedium'),
              decoration: const InputDecoration(isDense: true, border: InputBorder.none),
            ),
          ),
          Positioned(
            left: 28,
            top: 550,
            child: GestureDetector(
              onTap: () {
                // aksi logout nanti di sini
              },
              child: Image.asset(
                'assets/keluar.png',
                width: 99,
                height: 29,
              ),
            ),
          ),
          if (_showDropdown)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleDropdown,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      color: Colors.black.withAlpha(100),
                    ),
                  ),
                ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showDropdown ? -60 : -250,
            left: (screenWidth - 360) / 2,
            child: SlideTransition(
              position: _slideAnimation,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 360,
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 45,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const FaceDetectionPage()),
                              );
                              _toggleDropdown();
                            },
                            child: const _EllipseWithText(label: 'Foto', imageAsset: 'assets/pkamera.png'),
                          ),
                          GestureDetector(
                            onTap: () => _getImage(ImageSource.gallery),
                            child: const _EllipseWithText(label: 'Galeri', imageAsset: 'assets/pgaleri.png'),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _profileImage = null;
                              });
                              _toggleDropdown();
                            },
                            child: const _EllipseWithText(label: 'Hapus', imageAsset: 'assets/hapus.png'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EllipseWithText extends StatelessWidget {
  final String label;
  final String imageAsset;

  const _EllipseWithText({
    required this.label,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 71,
          height: 71,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: Colors.black.withAlpha(28),
              width: 1,
            ),
          ),
          child: Center(
            child: Image.asset(
              imageAsset,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'PoppinsMedium',
            color: Color(0xFF000000),
          ),
        ),
      ],
    );
  }
}
