import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'kategori_user.dart';
import 'manajemen_menu.dart';
import 'profile.dart';
import 'detail_pesanan.dart';  // Add this import

class FavoritPage extends StatefulWidget {
  const FavoritPage({super.key});

  @override
  State<FavoritPage> createState() => _FavoritPageState();
}

class _FavoritPageState extends State<FavoritPage> {
  String username = '';
  String role = 'user';
  String email = '';
  bool showDropdown = false;
  bool dropdownVisible = false;
  String selectedMenu = '';
  String selectedCategory = 'Rekomendasi';
  List<Map<String, dynamic>> menus = [];
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String? selectedMenuKey;

  Map<String, int> itemQuantities = {};
  Map<String, bool> highlightStates = {};

  final dbRef = FirebaseDatabase.instance.ref().child('menu');

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    listenMenus();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Pengguna';
      role = prefs.getString('role') ?? 'user';
      email = prefs.getString('email') ?? '';
    });
  }

  void listenMenus() {
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        setState(() {
          menus = [];
        });
        return;
      }

      final List<Map<String, dynamic>> tempMenus = [];
      data.forEach((key, value) {
        if (key != '1') {
          final menuMap = Map<String, dynamic>.from(value);
          menuMap['key'] = key;
          tempMenus.add(menuMap);
          if (!itemQuantities.containsKey(key)) {
            itemQuantities[key] = 0;
          } else {
            final int dbStock = int.tryParse(menuMap['stok']?.toString() ?? '0') ?? 0;
            if (itemQuantities[key]! > dbStock) {
              itemQuantities[key] = dbStock;
            }
          }
          if (!highlightStates.containsKey(key)) {
            highlightStates[key] = false;
          }
        }
      });

      setState(() {
        menus = tempMenus;
      });
    });
  }

  void incrementQuantity(String menuKey) {
    setState(() {
      final menu = menus.firstWhere((m) => m['key'] == menuKey, orElse: () => {});

      if (menu.isNotEmpty) {
        final int dbStock = int.tryParse(menu['stok']?.toString() ?? '0') ?? 0;
        int currentQuantity = itemQuantities[menuKey] ?? 0;

        if (currentQuantity < dbStock) {
          itemQuantities[menuKey] = currentQuantity + 1;
          highlightStates[menuKey] = true;
        } else {
          final snackBar = SnackBar(
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Stok "${menu['nama_menu']}" tidak mencukupi (Max: $dbStock)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'PoppinsMedium',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, right: 16, left: 16),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    });
  }

  void decrementQuantity(String menuKey) {
    setState(() {
      if ((itemQuantities[menuKey] ?? 0) > 0) {
        itemQuantities[menuKey] = (itemQuantities[menuKey] ?? 0) - 1;
        if (itemQuantities[menuKey] == 0) {
          highlightStates[menuKey] = false;
        }
      }
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const KategoriUser()),
          (route) => false,
    );
  }

  String getRoleImage() {
    switch (role) {
      case 'admin':
        return 'assets/roleowner.png';
      default:
        return 'assets/rolekasir.png';
    }
  }

  void toggleDropdown() {
    if (!showDropdown) {
      setState(() {
        showDropdown = true;
        dropdownVisible = true;
      });
    } else {
      setState(() {
        dropdownVisible = false;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            showDropdown = false;
          });
        }
      });
    }
  }

  Widget buildMenuItem(String title, double top) {
    bool isSelected = selectedMenu == title;
    return Positioned(
      top: top,
      left: 0,
      child: SizedBox(
        width: 284,
        child: Container(
          color: isSelected ? const Color(0xFFE5F4FF) : Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 29),
            title: Text(
              title,
              style: TextStyle(
                fontFamily: 'PoppinsMedium',
                fontSize: 16,
                color: isSelected ? const Color(0xFF40AFFF) : Colors.black,
              ),
            ),
            onTap: () {
              setState(() {
                selectedMenu = title;
              });
              toggleDropdown();
              if (title == 'Manajemen Menu') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManajemenMenuPage()),
                );
              }
              if (title == 'Profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(
                      usernameFromDatabase: username,
                      roleFromDatabase: role,
                      emailFromDatabase: email,
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget categoryButton(String label, double width) {
    final bool isSelected = selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0095FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMenus = menus.where((menu) {
      final kategori = menu['kategori']?.toString().toLowerCase() ?? '';
      final namaMenu = menu['nama_menu']?.toString().toLowerCase() ?? '';
      final selected = selectedCategory.toLowerCase();
      return kategori == selected && namaMenu.contains(searchQuery.toLowerCase());
    }).toList();

    // Calculate total items and total price
    int totalItems = itemQuantities.values.fold(0, (sum, quantity) => sum + quantity);
    double totalPrice = 0.0;
    List<Map<String, dynamic>> orderedItems = [];

    itemQuantities.forEach((menuKey, quantity) {
      if (quantity > 0) {
        final menu = menus.firstWhere((m) => m['key'] == menuKey, orElse: () => {});
        if (menu.isNotEmpty) {
          final hargaJual = double.tryParse(menu['harga_jual']?.toString() ?? '0') ?? 0.0;
          final diskonHarga = double.tryParse(menu['diskon']?.toString() ?? '0') ?? 0.0;
          final hargaSetelahDiskon = hargaJual - diskonHarga;
          totalPrice += hargaSetelahDiskon * quantity;

          orderedItems.add({
            'nama_menu': menu['nama_menu'],
            'quantity': quantity,
            'harga_total_item': hargaSetelahDiskon * quantity,
            'gambar_url': menu['gambar_url'], // <-- tambahkan ini
          });
        }
      }
    });

    final formattedTotalPrice = totalPrice % 1 == 0
        ? totalPrice.toInt().toString()
        : totalPrice.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          if (showDropdown) {
            toggleDropdown();
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned(
              left: 30,
              top: 51,
              child: GestureDetector(
                onTap: toggleDropdown,
                child: Image.asset('assets/titik3.png', width: 24, height: 24),
              ),
            ),
            Positioned(
              left: 320,
              top: 51,
              child: Image.asset('assets/notif.png', width: 24, height: 24),
            ),

            Positioned(
              left: 25,
              top: 105,
              child: Container(
                width: 225,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF888888), width: 1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/search.png', width: 20, height: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          style: const TextStyle(
                            fontFamily: 'PoppinsMedium',
                            fontSize: 12,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(bottom: 14),
                            border: InputBorder.none,
                            hintText: 'Cari Menu',
                            hintStyle: TextStyle(
                              fontFamily: 'PoppinsMedium',
                              fontSize: 12,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 260,
              top: 105,
              child: Container(
                width: 78,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF888888), width: 1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    'New Order',
                    style: TextStyle(
                      fontFamily: 'PoppinsMedium',
                      fontSize: 12,
                      color: Color(0xFFFE9728),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 187,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  categoryButton('Rekomendasi', 120),
                  categoryButton('Makanan', 100),
                  categoryButton('Minuman', 100),
                ],
              ),
            ),

            const Positioned(
              left: 20,
              top: 254,
              child: Text('Pilih Menu',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
            ),

            // Main content of menu items
            Positioned(
              left: 25,
              top: 280,
              right: 25,
              bottom: totalItems > 0 ? 20 + 47 + 10 : 20,
              child: filteredMenus.isEmpty
                  ? const Center(
                child: Text(
                  'Tidak ada menu',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 0),
                itemCount: filteredMenus.length,
                itemBuilder: (context, index) {
                  final menu = filteredMenus[index];
                  final namaMenu = menu['nama_menu'] ?? '-';
                  final hargaJual = double.tryParse(menu['harga_jual']?.toString() ?? '0') ?? 0.0;
                  final diskonHarga = double.tryParse(menu['diskon']?.toString() ?? '0') ?? 0.0;
                  final int dbStock = int.tryParse(menu['stok']?.toString() ?? '0') ?? 0;

                  final hargaSetelahDiskon = hargaJual - diskonHarga;
                  final hargaTampil = hargaSetelahDiskon % 1 == 0
                      ? hargaSetelahDiskon.toInt().toString()
                      : hargaSetelahDiskon.toStringAsFixed(2);

                  final gambar = menu['gambar_url'] ?? '';
                  final menuKey = menu['key'] as String;
                  final quantity = itemQuantities[menuKey] ?? 0;
                  final isHighlighted = highlightStates[menuKey] ?? false;

                  Color plusButtonColor = (quantity == 0) ? const Color(0xFF40AFFF) : Colors.transparent;
                  Color plusIconColor = (quantity == 0) ? Colors.white : Colors.black;
                  Border? plusButtonBorder = (quantity == 0)
                      ? null
                      : Border.all(color: Colors.black, width: 1.5);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? const Color(0xFF4D9AD1).withOpacity(0.3)
                          : Colors.white,
                      border: Border.all(
                        color: isHighlighted
                            ? const Color(0xFF4D9AD1)
                            : const Color(0xFF000000).withOpacity(0.5),
                        width: isHighlighted ? 1.5 : 0.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: gambar.isNotEmpty
                              ? Image.network(
                            gambar,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.fastfood,
                                size: 30),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                namaMenu,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp $hargaTampil',
                                style: const TextStyle(
                                  fontFamily: 'PoppinsSemiBold',
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Stok: $dbStock',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (quantity > 0)
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => decrementQuantity(menuKey),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(Icons.remove,
                                      color: Colors.black, size: 20),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'PoppinsBold',
                                    fontSize: 24,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        GestureDetector(
                          onTap: () => incrementQuantity(menuKey),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: (quantity >= dbStock) ? Colors.grey : plusButtonColor,
                              shape: BoxShape.circle,
                              border: (quantity >= dbStock)
                                  ? Border.all(color: Colors.grey, width: 1.5)
                                  : plusButtonBorder,
                            ),
                            child: Icon(
                              Icons.add,
                              color: (quantity >= dbStock) ? Colors.white : plusIconColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Detail Pesanan Button (appears only if totalItems > 0)
            if (totalItems > 0)
              Positioned(
                left: (MediaQuery.of(context).size.width - 316) / 2,
                bottom: 20,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPesananPage(
                          orderedItems: orderedItems,
                          totalPrice: totalPrice,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 316,
                    height: 47,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0095FF),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detail Pesanan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '$totalItems Item',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'RP $formattedTotalPrice',
                              style: const TextStyle(
                                fontFamily: 'PoppinsSemiBold',
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            Positioned(
              left: 65,
              top: 52,
              child: Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      username,
                      style: const TextStyle(
                        fontFamily: 'PoppinsMedium',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Image.asset(
                    getRoleImage(),
                    width: 44,
                    height: 15,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: showDropdown ? 0 : -300,
              top: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: dropdownVisible ? 1.0 : 0.0,
                child: Stack(
                  children: [
                    Container(
                      width: 284,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.white,
                    ),
                    Positioned(
                      left: 20,
                      top: 81,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfilePage(
                                usernameFromDatabase: username,
                                roleFromDatabase: role,
                                emailFromDatabase: email,
                              ),
                            ),
                          );
                        },
                        child: const Image(
                          image: AssetImage('assets/profiledropdown.png'),
                          width: 71,
                          height: 71,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 106,
                      left: 120,
                      child: Row(
                        children: [
                          Text(
                            role == 'admin' ? 'Admin' : username,
                            style: const TextStyle(
                              fontFamily: 'PoppinsMedium',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            getRoleImage(),
                            width: 44,
                            height: 15,
                          ),
                        ],
                      ),
                    ),
                    buildMenuItem('Dashboard', 206),
                    buildMenuItem('Manajemen Menu', 278),
                    buildMenuItem('Transaksi Penjualan', 347),
                    if (role == 'admin') buildMenuItem('Laporan Penjualan', 416),
                    Positioned(
                      left: 34,
                      top: 550,
                      child: GestureDetector(
                        onTap: logout,
                        child: Image.asset(
                          'assets/keluar.png',
                          width: 99,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}