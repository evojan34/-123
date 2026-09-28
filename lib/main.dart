import 'package:flutter/material.dart';

void main() {
  runApp(const LuxuryClinicCashierApp());
}

// -------------------------------------------------------------
// النماذج والبيانات
// -------------------------------------------------------------
enum UserRole { admin, cashier }

class AppUser {
  final String username;
  final String password;
  final String fullName;
  final UserRole role;

  AppUser({
    required this.username,
    required this.password,
    required this.fullName,
    required this.role,
  });
}

class Product {
  final String id;
  String name;
  double price; // د.ع
  int stock;
  int minStock;
  final bool isService;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.stock = 0,
    this.minStock = 5,
    this.isService = false,
  });
}

class CartItem {
  final Product product;
  int qty;
  double customPrice; // للسماح بتعديل السعر المباشر داخل السلة

  CartItem({required this.product, this.qty = 1, double? price})
      : customPrice = price ?? product.price;

  double get subtotal => customPrice * qty;
}

class SaleInvoice {
  final String invoiceNumber;
  final DateTime date;
  final List<CartItem> items;
  final double totalAmount;
  final String cashierName;

  SaleInvoice({
    required this.invoiceNumber,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.cashierName,
  });
}

class PurchaseRecord {
  final String id;
  final String productName;
  final int qty;
  final double unitCost;
  final String supplier;
  final DateTime date;

  PurchaseRecord({
    required this.id,
    required this.productName,
    required this.qty,
    required this.unitCost,
    required this.supplier,
    required this.date,
  });

  double get totalCost => qty * unitCost;
}

// الحالة العامة والبيانات المشتركة
class AppState {
  static String storeName = "عيادة ومستلزمات التمريض المتنقلة";
  static String storePhone = "0770 123 4567";
  static String storeAddress = "بغداد - خدمة التوصيل والرعاية المنزلية";

  // المستخدم الحالي المسجل
  static AppUser? currentUser;

  // الحسابات المعتمدة في النظام
  static List<AppUser> users = [
    AppUser(username: "admin", password: "123", fullName: "د. علي (المدير العام)", role: UserRole.admin),
    AppUser(username: "cashier1", password: "123", fullName: "ممرض أحمد (كاشير 1)", role: UserRole.cashier),
    AppUser(username: "cashier2", password: "123", fullName: "ممرضة فاطمة (كاشير 2)", role: UserRole.cashier),
  ];

  static List<Product> products = [
    Product(id: "1", name: "محلول ملحي معقم (Saline 500ml)", price: 3000, stock: 15, minStock: 5),
    Product(id: "2", name: "كانيولا وريدية معقمة قياس 20G", price: 1000, stock: 4, minStock: 5),
    Product(id: "3", name: "شاش طبي وبلاستر معقم", price: 2500, stock: 20, minStock: 5),
    Product(id: "4", name: "أنبوب قسطرة بولية سيليكون", price: 9000, stock: 2, minStock: 4),
    Product(id: "5", name: "جهاز قياس ضغط إلكتروني", price: 35000, stock: 6, minStock: 2),
    Product(id: "6", name: "خدمة: إعطاء حقنة وريدية/عضلية", price: 10000, isService: true),
    Product(id: "7", name: "خدمة: تضميد وتعقيم جروح عميقة", price: 20000, isService: true),
    Product(id: "8", name: "خدمة: تركيب قسطرة بولية مع تعقيم", price: 25000, isService: true),
  ];

  static List<SaleInvoice> sales = [];
  static List<PurchaseRecord> purchases = [];
  static int invoiceCounter = 1001;
}

// -------------------------------------------------------------
// التطبيق الرئيسي والثيم الذهبي الداكن
// -------------------------------------------------------------
class LuxuryClinicCashierApp extends StatelessWidget {
  const LuxuryClinicCashierApp({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color darkBg = Color(0xFF121418);
  static const Color darkCard = Color(0xFF1B1E24);
  static const Color darkBorder = Color(0xFF2C323D);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'كاشير العيادة التمريضية',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBg,
        primaryColor: gold,
        cardColor: darkCard,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: goldLight,
          surface: darkCard,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16191E),
          elevation: 0,
          titleTextStyle: TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: gold),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: LoginScreen(),
      ),
    );
  }
}

// -------------------------------------------------------------
// شاشة تسجيل الدخول للحسابات المتعددة
// -------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userCtrl = TextEditingController(text: "admin");
  final TextEditingController _passCtrl = TextEditingController(text: "123");
  String? _errorMessage;

  void _handleLogin() {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();

    final matchedUser = AppState.users.firstWhere(
      (u) => u.username == username && u.password == password,
      orElse: () => AppUser(username: "", password: "", fullName: "", role: UserRole.cashier),
    );

    if (matchedUser.username.isNotEmpty) {
      AppState.currentUser = matchedUser;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const Directionality(
            textDirection: TextDirection.rtl,
            child: MainNavigationScreen(),
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = "اسم المستخدم أو كلمة المرور غير صحيحة!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: LuxuryClinicCashierApp.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LuxuryClinicCashierApp.darkBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_hospital, size: 55, color: LuxuryClinicCashierApp.gold),
                const SizedBox(height: 12),
                const Text(
                  'نظام الكاشير التمريضي المتنقل',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'تسجيل دخول الموظفين والكادر الطبي',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _userCtrl,
                  decoration: InputDecoration(
                    labelText: 'اسم المستخدم',
                    prefixIcon: const Icon(Icons.person, color: LuxuryClinicCashierApp.gold),
                    filled: true,
                    fillColor: const Color(0xFF14161B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock, color: LuxuryClinicCashierApp.gold),
                    filled: true,
                    fillColor: const Color(0xFF14161B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LuxuryClinicCashierApp.gold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _handleLogin,
                  child: const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(height: 20),
                const Divider(color: LuxuryClinicCashierApp.darkBorder),
                const Text(
                  'حسابات للتجربة:\n• المدير: admin / 123\n• كاشير: cashier1 / 123',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// شاشة التنقل الرئيسية (Navigation)
// -------------------------------------------------------------
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = AppState.currentUser?.role == UserRole.admin;

    // الصفحات المتاحة بحسب صلاحية الحساب
    final List<Widget> pages = [
      const PosScreen(),
      const InventoryScreen(),
      if (isAdmin) const PurchasesScreen(),
      const SalesHistoryScreen(),
      if (isAdmin) const AnalyticsScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'الكاشير'),
      const BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'المخزون'),
      if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'المشتريات'),
      const BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'المبيعات'),
      if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'الإحصائيات'),
    ];

    return Scaffold(
      body: pages[_currentIndex >= pages.length ? 0 : _currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: LuxuryClinicCashierApp.darkBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex >= pages.length ? 0 : _currentIndex,
          backgroundColor: const Color(0xFF16191E),
          selectedItemColor: LuxuryClinicCashierApp.gold,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: navItems,
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 1. شاشة الكاشير مع إضافة منتج وتعديل السعر فورياً
// -------------------------------------------------------------
class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final List<CartItem> cart = [];
  String searchQuery = "";

  double get cartTotal => cart.fold(0, (sum, item) => sum + item.subtotal);

  void _addToCart(Product product) {
    if (!product.isService && product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('نفد مخزون "${product.name}"! لا يمكن إتمام البيع.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      final index = cart.indexWhere((c) => c.product.id == product.id);
      if (index >= 0) {
        if (!product.isService && cart[index].qty >= product.stock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('الكمية المطلوبة تتجاوز المخزون (${product.stock})'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
        cart[index].qty++;
      } else {
        cart.add(CartItem(product: product, qty: 1));
      }
    });
  }

  // إضافة منتج جديد مباشرة من واجهة البيع والكاشير
  void _addNewProductDirectly() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: "10");
    bool isService = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: LuxuryClinicCashierApp.darkCard,
            title: const Text('إضافة منتج/خدمة سريعة للكاشير', style: TextStyle(color: LuxuryClinicCashierApp.gold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المنتج أو الخدمة')),
                  const SizedBox(height: 8),
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر (د.ع)')),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('هل هي خدمة طبية؟ (بدون مخزون)', style: TextStyle(fontSize: 13)),
                    value: isService,
                    activeColor: LuxuryClinicCashierApp.gold,
                    onChanged: (val) => setDlgState(() => isService = val ?? false),
                  ),
                  if (!isService)
                    TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الكمية في المخزن')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text) ?? 0.0;
                  final stock = int.tryParse(stockCtrl.text) ?? 0;

                  if (name.isNotEmpty && price > 0) {
                    final newP = Product(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      price: price,
                      stock: stock,
                      isService: isService,
                    );
                    setState(() {
                      AppState.products.insert(0, newP);
                      _addToCart(newP); // إضافته للسلة مباشرة للزبون الحالي
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('إضافة وإدراج بالسلة', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // تعديل سعر المنتج الأصلي
  void _editProductPrice(Product product) {
    final priceCtrl = TextEditingController(text: product.price.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: LuxuryClinicCashierApp.darkCard,
          title: Text('تعديل سعر: ${product.name}', style: const TextStyle(color: LuxuryClinicCashierApp.gold, fontSize: 16)),
          content: TextField(
            controller: priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'السعر الجديد (د.ع)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold),
              onPressed: () {
                final newPrice = double.tryParse(priceCtrl.text);
                if (newPrice != null && newPrice > 0) {
                  setState(() {
                    product.price = newPrice;
                    // تحديث السعر في السلة أيضاً إذا كان مضافاً
                    for (var item in cart) {
                      if (item.product.id == product.id) item.customPrice = newPrice;
                    }
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ السعر', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  // تعديل السعر داخل السلة لعمل خصم خاص بالفاتورة الحالية
  void _editCartItemPrice(CartItem item) {
    final priceCtrl = TextEditingController(text: item.customPrice.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: LuxuryClinicCashierApp.darkCard,
          title: Text('تعديل السعر في الفاتورة فقط (${item.product.name})',
              style: const TextStyle(color: LuxuryClinicCashierApp.gold, fontSize: 14)),
          content: TextField(
            controller: priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'سعر الوحدة لهذه الفاتورة'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold),
              onPressed: () {
                final newPrice = double.tryParse(priceCtrl.text);
                if (newPrice != null) {
                  setState(() {
                    item.customPrice = newPrice;
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('تطبيق', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  void _completeSaleAndPrint() {
    if (cart.isEmpty) return;

    // خصم الكميات من المخزون
    for (var cartItem in cart) {
      if (!cartItem.product.isService) {
        cartItem.product.stock -= cartItem.qty;
      }
    }

    final newInvoice = SaleInvoice(
      invoiceNumber: "INV-${AppState.invoiceCounter++}",
      date: DateTime.now(),
      items: List.from(cart),
      totalAmount: cartTotal,
      cashierName: AppState.currentUser?.fullName ?? "كاشير عام",
    );

    setState(() {
      AppState.sales.insert(0, newInvoice);
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: ThermalReceiptDialog(invoice: newInvoice),
      ),
    ).then((_) {
      setState(() => cart.clear());
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = AppState.products
        .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('شاشة البيع والكاشير'),
            Text(
              'المستخدم: ${AppState.currentUser?.fullName ?? ""}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: LuxuryClinicCashierApp.gold, size: 28),
            tooltip: 'إضافة منتج جديد لواجهة البيع',
            onPressed: _addNewProductDirectly,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'تسجيل الخروج',
            onPressed: () {
              AppState.currentUser = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: LoginScreen())),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'بحث في المنتجات أو الخدمات...',
                prefixIcon: const Icon(Icons.search, color: LuxuryClinicCashierApp.gold),
                filled: true,
                fillColor: LuxuryClinicCashierApp.darkCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),

          // شبكة المنتجات مع أزرار تعديل الأسعار
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final p = filtered[idx];
                final bool isLowStock = !p.isService && p.stock <= p.minStock && p.stock > 0;
                final bool isOutOfStock = !p.isService && p.stock <= 0;

                return InkWell(
                  onTap: () => _addToCart(p),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: LuxuryClinicCashierApp.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOutOfStock
                            ? Colors.redAccent.withOpacity(0.5)
                            : isLowStock
                                ? Colors.orange.withOpacity(0.5)
                                : LuxuryClinicCashierApp.darkBorder,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              p.isService ? Icons.medical_services_outlined : Icons.medication,
                              color: LuxuryClinicCashierApp.gold,
                              size: 20,
                            ),
                            Row(
                              children: [
                                // زر تعديل السعر المباشر
                                InkWell(
                                  onTap: () => _editProductPrice(p),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                    child: Icon(Icons.edit_note, color: Colors.grey, size: 20),
                                  ),
                                ),
                                if (!p.isService)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isOutOfStock ? Colors.redAccent.withOpacity(0.2) : Colors.white10,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isOutOfStock ? 'نفد' : 'مخزون: ${p.stock}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isOutOfStock ? Colors.redAccent : Colors.grey,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          p.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${p.price.toInt()} د.ع',
                              style: const TextStyle(
                                color: LuxuryClinicCashierApp.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Icon(Icons.add_shopping_cart, size: 16, color: LuxuryClinicCashierApp.gold),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // لوحة السلة وإتمام البيع
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFF16191E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(top: BorderSide(color: LuxuryClinicCashierApp.darkBorder)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (cart.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cart.length,
                      itemBuilder: (ctx, i) {
                        final item = cart[i];
                        return Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.product.name,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // زر تعديل السعر للفاتورة فقط
                            IconButton(
                              icon: const Icon(Icons.price_change_outlined, size: 16, color: LuxuryClinicCashierApp.gold),
                              tooltip: 'تعديل السعر لهذه الفاتورة',
                              onPressed: () => _editCartItemPrice(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  if (item.qty > 1) {
                                    item.qty--;
                                  } else {
                                    cart.removeAt(i);
                                  }
                                });
                              },
                            ),
                            Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16, color: LuxuryClinicCashierApp.gold),
                              onPressed: () => _addToCart(item.product),
                            ),
                            SizedBox(
                              width: 80,
                              child: Text(
                                '${item.subtotal.toInt()} د.ع',
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                const Divider(color: LuxuryClinicCashierApp.darkBorder),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('المجموع الإجمالي:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '${cartTotal.toInt()} د.ع',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: LuxuryClinicCashierApp.gold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LuxuryClinicCashierApp.gold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.print, color: Colors.black),
                  label: Text(
                    'إتمام البيع وطباعة الفاتورة (${cart.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: cart.isEmpty ? null : _completeSaleAndPrint,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. إدارة المخزون
// -------------------------------------------------------------
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  void _openProductDialog({Product? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl = TextEditingController(text: existing != null ? existing.price.toInt().toString() : '');
    final stockCtrl = TextEditingController(text: existing != null ? existing.stock.toString() : '10');
    final minStockCtrl = TextEditingController(text: existing != null ? existing.minStock.toString() : '5');
    bool isService = existing?.isService ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: LuxuryClinicCashierApp.darkCard,
            title: Text(existing == null ? 'إضافة صنف جديد' : 'تعديل الصنف',
                style: const TextStyle(color: LuxuryClinicCashierApp.gold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الصنف أو الخدمة')),
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر (د.ع)')),
                  CheckboxListTile(
                    title: const Text('هل هي خدمة طبية؟ (بدون مخزون)'),
                    value: isService,
                    activeColor: LuxuryClinicCashierApp.gold,
                    onChanged: (val) => setDlgState(() => isService = val ?? false),
                  ),
                  if (!isService) ...[
                    TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الكمية المتوفرة')),
                    TextField(controller: minStockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'حد تنبيه النفاد')),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text) ?? 0.0;
                  final stock = int.tryParse(stockCtrl.text) ?? 0;
                  final minStock = int.tryParse(minStockCtrl.text) ?? 5;

                  if (name.isNotEmpty) {
                    setState(() {
                      if (existing != null) {
                        existing.name = name;
                        existing.price = price;
                        existing.stock = stock;
                        existing.minStock = minStock;
                      } else {
                        AppState.products.add(Product(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          price: price,
                          stock: stock,
                          minStock: minStock,
                          isService: isService,
                        ));
                      }
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('حفظ', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات والمخزون'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة صنف جديد',
            onPressed: () => _openProductDialog(),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: AppState.products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final p = AppState.products[i];
          final bool isLowStock = !p.isService && p.stock <= p.minStock;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: LuxuryClinicCashierApp.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLowStock ? Colors.redAccent.withOpacity(0.6) : LuxuryClinicCashierApp.darkBorder,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: LuxuryClinicCashierApp.gold.withOpacity(0.15),
                  child: Icon(
                    p.isService ? Icons.medical_services : Icons.inventory_2,
                    color: LuxuryClinicCashierApp.gold,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        '${p.price.toInt()} د.ع',
                        style: const TextStyle(color: LuxuryClinicCashierApp.gold, fontWeight: FontWeight.bold),
                      ),
                      if (!p.isService)
                        Text(
                          'المتوفر: ${p.stock} (الحد الأدنى: ${p.minStock})',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLowStock ? Colors.redAccent : Colors.grey,
                            fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey),
                  onPressed: () => _openProductDialog(existing: p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    setState(() => AppState.products.removeAt(i));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// 3. شاشة المشتريات والموردين
// -------------------------------------------------------------
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  void _addPurchaseDialog() {
    Product? selectedProduct;
    final qtyCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final supplierCtrl = TextEditingController();

    final physicalProducts = AppState.products.where((p) => !p.isService).toList();
    if (physicalProducts.isNotEmpty) selectedProduct = physicalProducts.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: LuxuryClinicCashierApp.darkCard,
            title: const Text('تسجيل فاتورة شراء جديدة', style: TextStyle(color: LuxuryClinicCashierApp.gold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Product>(
                    value: selectedProduct,
                    dropdownColor: LuxuryClinicCashierApp.darkCard,
                    decoration: const InputDecoration(labelText: 'اختر المنتج لزيادة مخزونه'),
                    items: physicalProducts.map((p) {
                      return DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (val) => setDlgState(() => selectedProduct = val),
                  ),
                  TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الكمية المشتراة')),
                  TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تكلفة المفرد (د.ع)')),
                  TextField(controller: supplierCtrl, decoration: const InputDecoration(labelText: 'اسم المورد أو المذخر')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold),
                onPressed: () {
                  if (selectedProduct == null) return;
                  final qty = int.tryParse(qtyCtrl.text) ?? 0;
                  final cost = double.tryParse(costCtrl.text) ?? 0.0;
                  final supplier = supplierCtrl.text.trim();

                  if (qty > 0) {
                    setState(() {
                      selectedProduct!.stock += qty;
                      AppState.purchases.insert(
                        0,
                        PurchaseRecord(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          productName: selectedProduct!.name,
                          qty: qty,
                          unitCost: cost,
                          supplier: supplier.isEmpty ? 'مورد عام' : supplier,
                          date: DateTime.now(),
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('تسجيل ورفع المخزون', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المشتريات والموردين'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: 'إضافة شراء جديد',
            onPressed: _addPurchaseDialog,
          )
        ],
      ),
      body: AppState.purchases.isEmpty
          ? const Center(child: Text('لا توجد فواتير شراء مسجلة بعد.', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: AppState.purchases.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final item = AppState.purchases[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: LuxuryClinicCashierApp.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: LuxuryClinicCashierApp.darkBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('المورد: ${item.supplier}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('الكمية المضافة: +${item.qty}', style: const TextStyle(fontSize: 12, color: Colors.greenAccent)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${item.totalCost.toInt()} د.ع',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold, fontSize: 14)),
                          Text('${item.date.year}/${item.date.month}/${item.date.day}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// -------------------------------------------------------------
// 4. سجل المبيعات
// -------------------------------------------------------------
class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل المبيعات والفواتير')),
      body: AppState.sales.isEmpty
          ? const Center(child: Text('لا توجد مبيعات حتى الآن.', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: AppState.sales.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final invoice = AppState.sales[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: LuxuryClinicCashierApp.darkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: LuxuryClinicCashierApp.darkBorder),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${invoice.invoiceNumber} — ${invoice.totalAmount.toInt()} د.ع',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold)),
                    subtitle: Text(
                      'الكاشير: ${invoice.cashierName}\nالتاريخ: ${invoice.date.year}/${invoice.date.month}/${invoice.date.day} | العناصر: ${invoice.items.length}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.print, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: ThermalReceiptDialog(invoice: invoice),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// -------------------------------------------------------------
// 5. شاشة الإحصائيات (خاصة بالمدير)
// -------------------------------------------------------------
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final todaySales = AppState.sales
        .where((s) => s.date.year == now.year && s.date.month == now.month && s.date.day == now.day)
        .fold(0.0, (sum, s) => sum + s.totalAmount);

    final monthSales = AppState.sales
        .where((s) => s.date.year == now.year && s.date.month == now.month)
        .fold(0.0, (sum, s) => sum + s.totalAmount);

    final totalPurchases = AppState.purchases.fold(0.0, (sum, p) => sum + p.totalCost);
    final lowStockCount = AppState.products.where((p) => !p.isService && p.stock <= p.minStock).length;

    return Scaffold(
      appBar: AppBar(title: const Text('الإحصائيات والتقارير المالية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _kpiCard('مبيعات اليوم', '${todaySales.toInt()} د.ع', Icons.today, Colors.greenAccent)),
              const SizedBox(width: 10),
              Expanded(child: _kpiCard('مبيعات الشهر', '${monthSales.toInt()} د.ع', Icons.calendar_month, LuxuryClinicCashierApp.gold)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _kpiCard('عدد الفواتير', '${AppState.sales.length}', Icons.receipt, Colors.lightBlueAccent)),
              const SizedBox(width: 10),
              Expanded(child: _kpiCard('تنبيهات النفاد', '$lowStockCount أصناف', Icons.warning_amber, Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 10),
          _kpiCard('إجمالي تكلفة المشتريات', '${totalPurchases.toInt()} د.ع', Icons.account_balance_wallet, Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _kpiCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LuxuryClinicCashierApp.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LuxuryClinicCashierApp.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// حوار وطباعة الفاتورة الحرارية (80mm Thermal Receipt)
// -------------------------------------------------------------
class ThermalReceiptDialog extends StatelessWidget {
  final SaleInvoice invoice;

  const ThermalReceiptDialog({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 330,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_hospital, size: 40, color: Colors.black87),
              const SizedBox(height: 4),
              Text(
                AppState.storeName,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                AppState.storeAddress,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 11),
              ),
              Text(
                'هاتف: ${AppState.storePhone}',
                style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.black87, thickness: 1),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('فاتورة: ${invoice.invoiceNumber}', style: const TextStyle(color: Colors.black, fontSize: 11)),
                  Text(
                    '${invoice.date.year}/${invoice.date.month}/${invoice.date.day} ${invoice.date.hour}:${invoice.date.minute}',
                    style: const TextStyle(color: Colors.black, fontSize: 11),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('الكاشير: ${invoice.cashierName}', style: const TextStyle(color: Colors.black, fontSize: 11)),
                ],
              ),
              const Divider(color: Colors.black54, thickness: 0.8),

              // قائمة المواد المباعة
              ...invoice.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.product.name} (x${item.qty})',
                            style: const TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ),
                        Text(
                          '${item.subtotal.toInt()} د.ع',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  )),

              const Divider(color: Colors.black87, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المجموع الكلي:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    '${invoice.totalAmount.toInt()} د.ع',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('شكراً لثقتكم بنا — نتمنى لكم دوام الصحة 🌸',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 11, fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.bluetooth_searching, size: 18),
                      label: const Text('طباعة Bluetooth'),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم إرسال أمر الطباعة إلى الطابعة الحرارية بنجاح 🖨️'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
