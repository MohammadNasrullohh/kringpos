import 'package:flutter/material.dart';
import 'cash_payment_page.dart';

class DetailPesananPage extends StatefulWidget {
  final List<Map<String, dynamic>> orderedItems;
  final double totalPrice;

  const DetailPesananPage({
    super.key,
    required this.orderedItems,
    required this.totalPrice,
  });

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  String selectedMeja = '07';
  String selectedType = 'Dine In';
  String selectedPayment = 'Cash';
  OverlayEntry? _overlayEntry;
  final GlobalKey _mejaKey = GlobalKey();

  void _toggleDropdownOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    final renderBox = _mejaKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + size.height,
        width: size.width,
        child: _buildMejaDropdown(removeOverlay: true),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedTotalPrice = widget.totalPrice % 1 == 0
        ? widget.totalPrice.toInt().toString()
        : widget.totalPrice.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 25),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Detail Pesanan',
                          style: TextStyle(
                            fontFamily: 'PoppinsMedium',
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 0.5, color: const Color(0xFF9B9797)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(child: _buildMejaSelector()),
                              const SizedBox(width: 12),
                              Flexible(
                                child: _buildDropdownBox(
                                  value: selectedType,
                                  items: ['Dine In', 'Take Away'],
                                  onChanged: (val) => setState(() => selectedType = val),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const DashedLine(width: double.infinity),
                        const SizedBox(height: 24),
                        const Text('Item yang dipilih',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                        const SizedBox(height: 12),
                        ...widget.orderedItems.map((item) {
                          final subTotal = (item['harga_total_item'] as num).toDouble();
                          final quantity = item['quantity'] as int;
                          final hargaSatuan = subTotal ~/ quantity;
                          final imageUrl = item['gambar_url']?.toString();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: imageUrl != null && imageUrl.isNotEmpty
                                      ? Image.network(
                                    imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.fastfood, size: 30),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['nama_menu'].toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontFamily: 'Poppins', fontSize: 12)),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text('Rp $hargaSatuan',
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 4),
                                          Text('x $quantity',
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 12,
                                                  color: Color(0xFF888888))),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text('Rp ${subTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                        const Text('Metode Pembayaran',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildPaymentButton('Cash', Icons.payments)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildPaymentButton('Qris', Icons.qr_code)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('No Meja', selectedMeja),
                              const SizedBox(height: 4),
                              _buildDetailRow('Status Pesanan', selectedType),
                              const SizedBox(height: 4),
                              _buildDetailRow('Total', 'Rp $formattedTotalPrice'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: SizedBox(
                            width: 316,
                            height: 47,
                            child: ElevatedButton(
                              onPressed: () {
                                if (selectedPayment == 'Cash') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CashPaymentPage(
                                        totalBayar: widget.totalPrice,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                        Text('Fitur QRIS belum tersedia')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0095FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'Order Pesanan',
                                style: TextStyle(
                                  fontFamily: 'PoppinsSemiBold',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMejaSelector() {
    return GestureDetector(
      key: _mejaKey,
      onTap: _toggleDropdownOverlay,
      child: Container(
        height: 33,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFCCCCCC), width: 1),
            left: BorderSide(color: Color(0xFFCCCCCC), width: 1),
            right: BorderSide(color: Color(0xFFCCCCCC), width: 1),
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text('No Meja $selectedMeja',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontFamily: 'Poppins')),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildMejaDropdown({bool removeOverlay = false}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(color: Color(0xFFCCCCCC), width: 1),
          right: BorderSide(color: Color(0xFFCCCCCC), width: 1),
          bottom: BorderSide(color: Color(0xFFCCCCCC), width: 1),
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        children: List.generate(20, (index) {
          final number = (index + 1).toString().padLeft(2, '0');
          final isSelected = selectedMeja == number;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedMeja = number;
              });
              if (removeOverlay) {
                _overlayEntry?.remove();
                _overlayEntry = null;
              }
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0095FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                number,
                style: TextStyle(
                  fontFamily: 'AnekBangla-Regular',
                  fontSize: 11,
                  color: isSelected ? Colors.white : const Color(0xFF888888),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDropdownBox({
    required String value,
    required List<String> items,
    required void Function(String) onChanged,
  }) {
    return Container(
      height: 33,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD6D6D6), width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          dropdownColor: Colors.white,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.black,
          ),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  Widget _buildPaymentButton(String method, IconData icon) {
    final isSelected = selectedPayment == method;
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: () => setState(() => selectedPayment = method),
        icon: Icon(icon, size: 18),
        label: Text(method,
            style: const TextStyle(fontFamily: 'PoppinsMedium', fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF0095FF) : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          side: BorderSide(
            color: isSelected ? const Color(0xFF0095FF) : Colors.grey,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class DashedLine extends StatelessWidget {
  final double width;
  final Color color;

  const DashedLine({
    super.key,
    required this.width,
    this.color = const Color(0xFFCACAFE),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 6.0;
          const dashSpace = 4.0;
          final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
