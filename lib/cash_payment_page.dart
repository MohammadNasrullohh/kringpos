import 'package:flutter/material.dart';
import 'transaksi_cash_berhasil.dart'; // Import halaman tujuan

class CashPaymentPage extends StatefulWidget {
  final double totalBayar;

  const CashPaymentPage({Key? key, required this.totalBayar}) : super(key: key);

  @override
  State<CashPaymentPage> createState() => _CashPaymentPageState();
}

class _CashPaymentPageState extends State<CashPaymentPage> {
  String inputBayar = '';

  void onNumberTap(String value) {
    setState(() {
      inputBayar += value;
    });
  }

  void onClear() {
    setState(() {
      inputBayar = '';
    });
  }

  void onDelete() {
    setState(() {
      if (inputBayar.isNotEmpty) {
        inputBayar = inputBayar.substring(0, inputBayar.length - 1);
      }
    });
  }

  double get nominalBayar => double.tryParse(inputBayar.replaceAll('.', '')) ?? 0;
  double get kembalian => nominalBayar - widget.totalBayar;

  @override
  Widget build(BuildContext context) {
    final formattedNominalBayar = inputBayar.isEmpty ? '0' : inputBayar;
    final formattedKembalian = kembalian >= 0 ? 'Rp ${kembalian.toStringAsFixed(0)}' : 'Rp 0';

    final List<String> labels = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      'C', '0', '00',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            fontFamily: 'PoppinsMedium',
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset('assets/right.png'),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 280,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF40AFFF),
                    Color(0xFF258BD4),
                  ],
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'PoppinsMedium',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RP ${widget.totalBayar.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'PoppinsBold',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 1, color: Colors.white),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kembalian :',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'PoppinsMedium',
                        ),
                      ),
                      Text(
                        formattedKembalian,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'PoppinsMedium',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Nominal Bayar',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Rp ',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    color: Color(0xFF888888),
                  ),
                ),
                Expanded(
                  child: Text(
                    formattedNominalBayar,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 35,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double cellWidth = constraints.maxWidth / 3;
                        double cellHeight = constraints.maxHeight / 4;
                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: labels.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: cellWidth / cellHeight,
                          ),
                          itemBuilder: (context, index) {
                            final label = labels[index];
                            return GestureDetector(
                              onTap: () {
                                if (label == 'C') {
                                  onClear();
                                } else {
                                  onNumberTap(label);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: Color(0xFFD9D9D9), width: 1),
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontFamily: 'PoppinsMedium',
                                      color: Color(0xFF888888),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(color: Color(0xFFD9D9D9), width: 1),
                              ),
                              child: const Center(
                                child: Icon(Icons.backspace_outlined, color: Color(0xFF888888)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (nominalBayar >= widget.totalBayar) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TransaksiCashBerhasilPage(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Nominal kurang')),
                                );
                              }
                            },
                            child: Container(
                              color: const Color(0xFF0095FF),
                              child: const Center(
                                child: Text(
                                  'Lanjut',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'PoppinsMedium',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
