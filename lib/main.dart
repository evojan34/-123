import 'package:flutter/material.dart';

void main() {
  runApp(const LuxuryClinicCashierApp());
}

// -------------------------------------------------------------
// النماذج والبيانات (Models)
// -------------------------------------------------------------
enum UserRole { admin, cashier }

class AppUser {
  final String username;
  String password;
  String fullName;
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
  double price;
  int stock;
  final int minStock;
  final bool isService;
  String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.stock = 0,
    this.minStock = 5,
    this.isService = false,
    this.imageUrl = "",
  });
}

class CartItem {
  final Product product;
  int qty;
  double customPrice;

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
  final String cashierUsername;

  SaleInvoice({
    required this.invoiceNumber,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.cashierName,
    required this.cashierUsername,
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

// -------------------------------------------------------------
// الحالة العامة (State)
// -------------------------------------------------------------
class AppState {
  static String storeName = "عيادة ومستلزمات التمريض المتنقلة";
  static String storePhone = "0770 123 4567";
  static String storeAddress = "بغداد - الرعاية السريرية والمنزلية الفائقة";

  static AppUser? currentUser;
  static List<AppUser> users = [];
  static String recoverySecret = "123456";

  static bool get hasAdmin => users.any((u) => u.role == UserRole.admin);

  static List<Product> products = [
    Product(
      id: "1",
      name: "محلول ملحي معقم (Saline 500ml)",
      price: 3000,
      stock: 25,
      minStock: 5,
      imageUrl: "https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?w=300&q=80",
    ),
    Product(
      id: "2",
      name: "كانيولا وريدية قياس 20G وردي",
      price: 1000,
      stock: 30,
      minStock: 10,
      imageUrl: "https://images.unsplash.com/photo-1583912267670-6575ad362e5b?w=300&q=80",
    ),
    Product(
      id: "3",
      name: "شاش طبي وبلاستر معقم",
      price: 2500,
      stock: 20,
      minStock: 5,
      imageUrl: "https://images.unsplash.com/photo-1603398938378-e54eab446dde?w=300&q=80",
    ),
    Product(
      id: "4",
      name: "جهاز قياس ضغط إلكتروني",
      price: 40000,
      stock: 5,
      minStock: 2,
      imageUrl: "https://images.unsplash.com/photo-1631815588090-d4bfec5b1ccb?w=300&q=80",
    ),
    Product(
      id: "5",
      name: "خدمة: إعطاء مغذي وتثبيت كانيولا",
      price: 15000,
      isService: true,
      imageUrl: "https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=300&q=80",
    ),
  ];

  static List<SaleInvoice> sales = [];
  static List<PurchaseRecord> purchases = [];
  static int invoiceCounter = 1001;
}

// -------------------------------------------------------------
// التطبيق الرئيسي والثيم
// -------------------------------------------------------------
class LuxuryClinicCashierApp extends StatelessWidget {
  const LuxuryClinicCashierApp({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color darkCard = Color(0xFF171A21);
  static const Color darkBorder = Color(0xFF262A34);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'كاشير العيادة التمريضية',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: darkBg,
        primaryColor: gold,
        cardColor: darkCard,
        colorScheme: const ColorScheme.dark(primary: gold, surface: darkCard),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF13151B),
          elevation: 0,
          titleTextStyle: TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: gold),
        ),
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: AppState.hasAdmin ? const LoginScreen() : const InitialAdminSetupScreen(),
      ),
    );
  }
}

// -------------------------------------------------------------
// شاشة تأسيس حساب المدير العام لأول مرة
// -------------------------------------------------------------
class InitialAdminSetupScreen extends StatefulWidget {
  const InitialAdminSetupScreen({super.key});

  @override
  State<InitialAdminSetupScreen> createState() => _InitialAdminSetupScreenState();
}

class _InitialAdminSetupScreenState extends State<InitialAdminSetupScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();
  final TextEditingController _recoveryCtrl = TextEditingController();
  String? _error;

  void _saveAdmin() {
    final name = _nameCtrl.text.trim();
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final confirmPass = _confirmPassCtrl.text.trim();
    final recovery = _recoveryCtrl.text.trim();

    if (name.isEmpty || user.isEmpty || pass.isEmpty || recovery.isEmpty) {
      setState(() => _error = "يرجى ملء جميع الحقول المطلوبة");
      return;
    }

    if (pass != confirmPass) {
      setState(() => _error = "الرمز السري غير متطابق!");
      return;
    }

    final admin = AppUser(
      fullName: name,
      username: user,
      password: pass,
      role: UserRole.admin,
    );

    AppState.users.add(admin);
    AppState.currentUser = admin;
    AppState.recoverySecret = recovery;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: MainNavigationScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: LuxuryClinicCashierApp.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LuxuryClinicCashierApp.gold),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, size: 60, color: LuxuryClinicCashierApp.gold),
                const SizedBox(height: 12),
                const Text('تأسيس حساب المدير العام', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold)),
                const Text('قم بتعيين حسابك الرئيسي ورمز الاستعادة الاحتياطي', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 20),
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'الاسم الكامل للمدير', prefixIcon: Icon(Icons.badge))),
                const SizedBox(height: 12),
                TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'اسم المستخدم (Username)', prefixIcon: Icon(Icons.person))),
                const SizedBox(height: 12),
                TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'الرمز السري الخاص', prefixIcon: Icon(Icons.lock))),
                const SizedBox(height: 12),
                TextField(controller: _confirmPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'تأكيد الرمز السري', prefixIcon: Icon(Icons.lock_outline))),
                const SizedBox(height: 12),
                TextField(controller: _recoveryCtrl, decoration: const InputDecoration(labelText: 'رمز الأمان الاحتياطي للاستعادة', prefixIcon: Icon(Icons.vpn_key, color: Colors.amber))),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LuxuryClinicCashierApp.gold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _saveAdmin,
                  child: const Text('حفظ والدخول إلى النظام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
// تسجيل الدخول
// -------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  String? _errorMessage;

  void _handleLogin() {
    final username = _userCtrl.text.trim();
    final password = _passCtrl.text.trim();

    final matched = AppState.users.firstWhere(
      (u) => u.username.toLowerCase() == username.toLowerCase() && u.password == password,
      orElse: () => AppUser(username: "", password: "", fullName: "", role: UserRole.cashier),
    );

    if (matched.username.isNotEmpty) {
      AppState.currentUser = matched;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: MainNavigationScreen()),
        ),
      );
    } else {
      setState(() => _errorMessage = "اسم المستخدم أو الرمز السري غير صحيح!");
    }
  }

  void _openForgotPasswordDialog() {
    final userCtrl = TextEditingController();
    final recoveryCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    String? dialogError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: LuxuryClinicCashierApp.darkCard,
            title: const Text('استعادة الرمز السري', style: TextStyle(color: LuxuryClinicCashierApp.gold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('أدخل اسم المستخدم ورمز الأمان لتعيين رمز جديد.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'اسم المستخدم')),
                  const SizedBox(height: 10),
                  TextField(controller: recoveryCtrl, decoration: const InputDecoration(labelText: 'رمز الأمان الاحتياطي')),
                  const SizedBox(height: 10),
                  TextField(controller: newPassCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'الرمز السري الجديد')),
                  if (dialogError != null) ...[
                    const SizedBox(height: 8),
                    Text(dialogError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold, foregroundColor: Colors.black),
                onPressed: () {
                  final targetUser = userCtrl.text.trim();
                  final recoveryInput = recoveryCtrl.text.trim();
                  final newPassword = newPassCtrl.text.trim();

                  final userIndex = AppState.users.indexWhere((u) => u.username.toLowerCase() == targetUser.toLowerCase());
                  if (userIndex == -1) {
                    setDlg(() => dialogError = "اسم المستخدم غير مسجل!");
                    return;
                  }
                  if (recoveryInput != AppState.recoverySecret) {
                    setDlg(() => dialogError = "رمز الأمان الاحتياطي غير صحيح!");
                    return;
                  }
                  if (newPassword.isEmpty) {
                    setDlg(() => dialogError = "يرجى كتابة رمز سري جديد");
                    return;
                  }

                  AppState.users[userIndex].password = newPassword;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم استعادة وتحديث الرمز بنجاح!'), backgroundColor: Colors.green),
                  );
                },
                child: const Text('تأكيد الاستعادة'),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: LuxuryClinicCashierApp.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LuxuryClinicCashierApp.darkBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_hospital, size: 55, color: LuxuryClinicCashierApp.gold),
                const SizedBox(height: 12),
                const Text('نظام الكاشير التمريضي المتطور', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold)),
                const Text('تسجيل الدخول للمدير أو الكاشير', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 24),
                TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'اسم المستخدم', prefixIcon: Icon(Icons.person, color: LuxuryClinicCashierApp.gold))),
                const SizedBox(height: 14),
                TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'الرمز السري', prefixIcon: Icon(Icons.lock, color: LuxuryClinicClinicAppColor.gold))),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _openForgotPasswordDialog,
                    child: const Text('نسيت كلمة المرور؟', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                ),
                if (_errorMessage != null) ...[
                  Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                  const SizedBox(height: 10),
                ],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LuxuryClinicClinicAppColor {
  static const Color gold = Color(0xFFD4AF37);
}

// -------------------------------------------------------------
// شاشة التنقل الرئيسية (5 أقسام كاملة بدون نقص)
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

    final List<Widget> pages = [
      const PosScreen(),
      const InventoryScreen(),
      const PurchasesScreen(),
      const SalesHistoryScreen(),
      isAdmin ? const AdminMonthlyAuditScreen() : const UserPersonalAuditScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'الكاشير'),
      const BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'المخزن'),
      const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'المشتريات'),
      const BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'المبيعات'),
      BottomNavigationBarItem(
        icon: const Icon(Icons.assessment),
        label: isAdmin ? 'الجرد والإحصاء' : 'جردي الشخصي',
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: LuxuryClinicCashierApp.darkBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFF13151B),
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
// 1. شاشة البيع والكاشير
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
        SnackBar(content: Text('نفد مخزون "${product.name}"!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      final index = cart.indexWhere((c) => c.product.id == product.id);
      if (index >= 0) {
        if (!product.isService && cart[index].qty >= product.stock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('الكمية تجاوزت المخزون (${product.stock})'), backgroundColor: Colors.orange),
          );
          return;
        }
        cart[index].qty++;
      } else {
        cart.add(CartItem(product: product, qty: 1));
      }
    });
  }

  void _addNewProductDirectly() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: "10");
    final imgCtrl = TextEditingController();
    bool isService = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: LuxuryClinicCashierApp.darkCard,
            title: const Text('إضافة مادة لواجهة الكاشير', style: TextStyle(color: LuxuryClinicCashierApp.gold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المادة')),
                  const SizedBox(height: 8),
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر (د.ع)')),
                  const SizedBox(height: 8),
                  TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'رابط صورة المادة (URL)')),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('خدمة طبية؟ (بدون مخزون)', style: TextStyle(fontSize: 13)),
                    value: isService,
                    activeColor: LuxuryClinicCashierApp.gold,
                    onChanged: (val) => setDlg(() => isService = val ?? false),
                  ),
                  if (!isService)
                    TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الكمية الأولية بالمخزن')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold, foregroundColor: Colors.black),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text) ?? 0.0;
                  final stock = int.tryParse(stockCtrl.text) ?? 0;

                  if (name.isNotEmpty && price > 0) {
                    final newProduct = Product(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      price: price,
                      stock: stock,
                      isService: isService,
                      imageUrl: imgCtrl.text.trim(),
                    );

                    setState(() {
                      AppState.products.insert(0, newProduct);
                      _addToCart(newProduct);
                    });

                    Navigator.pop(ctx);
                  }
                },
                child: const Text('إضافة وإدراج بالسلة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editProductPrice(Product product) {
    final priceCtrl = TextEditingController(text: product.price.toInt().toString());
    final imgCtrl = TextEditingController(text: product.imageUrl);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: LuxuryClinicCashierApp.darkCard,
          title: Text('تعديل سعر وصورة: ${product.name}', style: const TextStyle(color: LuxuryClinicCashierApp.gold, fontSize: 15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'السعر الجديد (د.ع)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: imgCtrl,
                decoration: const InputDecoration(labelText: 'تحديث رابط صورة المادة (URL)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold, foregroundColor: Colors.black),
              onPressed: () {
                final newPrice = double.tryParse(priceCtrl.text);
                if (newPrice != null && newPrice > 0) {
                  setState(() {
                    product.price = newPrice;
                    product.imageUrl = imgCtrl.text.trim();
                    for (var item in cart) {
                      if (item.product.id == product.id) {
                        item.customPrice = newPrice;
                      }
                    }
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ التعديل'),
            ),
          ],
        ),
      ),
    );
  }

  void _editCartItemPrice(CartItem item) {
    final priceCtrl = TextEditingController(text: item.customPrice.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: LuxuryClinicCashierApp.darkCard,
          title: Text('تعديل السعر للفاتورة فقط (${item.product.name})', style: const TextStyle(color: LuxuryClinicCashierApp.gold, fontSize: 13)),
          content: TextField(
            controller: priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'سعر المفرد المخفض'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold, foregroundColor: Colors.black),
              onPressed: () {
                final newPrice = double.tryParse(priceCtrl.text);
                if (newPrice != null && newPrice >= 0) {
                  setState(() => item.customPrice = newPrice);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('تطبيق التخفيض'),
            ),
          ],
        ),
      ),
    );
  }

  void _completeSaleAndPrint() {
    if (cart.isEmpty) return;

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
      cashierUsername: AppState.currentUser?.username ?? "unknown",
    );

    setState(() {
      AppState.sales.insert(0, newInvoice);
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(textDirection: TextDirection.rtl, child: ThermalReceiptDialog(invoice: newInvoice)),
    ).then((_) => setState(() => cart.clear()));
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
            Text('الكاشير: ${AppState.currentUser?.fullName ?? ""}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box, color: LuxuryClinicCashierApp.gold, size: 28),
            tooltip: 'إضافة مادة جديدة',
            onPressed: _addNewProductDirectly,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'بحث في المواد والعلاجات والخدمات...',
                prefixIcon: const Icon(Icons.search, color: LuxuryClinicCashierApp.gold),
                filled: true,
                fillColor: LuxuryClinicCashierApp.darkCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.82,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final p = filtered[idx];
                final bool isOut = !p.isService && p.stock <= 0;

                return Container(
                  decoration: BoxDecoration(
                    color: LuxuryClinicCashierApp.darkCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isOut ? Colors.redAccent : LuxuryClinicCashierApp.darkBorder),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => _addToCart(p),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                p.imageUrl.isNotEmpty
                                    ? Image.network(
                                        p.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.white10,
                                          child: const Icon(Icons.medical_services_outlined, size: 36, color: Colors.grey),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.white10,
                                        child: Icon(
                                          p.isService ? Icons.medical_services : Icons.medication,
                                          size: 38,
                                          color: LuxuryClinicCashierApp.gold,
                                        ),
                                      ),
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: InkWell(
                                    onTap: () => _editProductPrice(p),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: LuxuryClinicCashierApp.gold),
                                      ),
                                      child: const Icon(Icons.edit, size: 16, color: LuxuryClinicCashierApp.gold),
                                    ),
                                  ),
                                ),
                                if (!p.isService)
                                  Positioned(
                                    bottom: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isOut ? Colors.redAccent : Colors.black87,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isOut ? 'نفد' : 'مخزون: ${p.stock}',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${p.price.toInt()} د.ع',
                                        style: const TextStyle(color: LuxuryClinicCashierApp.gold, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const Icon(Icons.add_shopping_cart, size: 16, color: LuxuryClinicCashierApp.gold),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFF13151B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(top: BorderSide(color: LuxuryClinicCashierApp.darkBorder)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (cart.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 110),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cart.length,
                      itemBuilder: (ctx, i) {
                        final item = cart[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(item.product.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                              ),
                              IconButton(
                                icon: const Icon(Icons.price_change, size: 16, color: LuxuryClinicCashierApp.gold),
                                tooltip: 'تعديل السعر للفاتورة فقط',
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
                          ),
                        );
                      },
                    ),
                  ),
                const Divider(color: LuxuryClinicCashierApp.darkBorder),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('المجموع الإجمالي:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text(
                      '${cartTotal.toInt()} د.ع',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LuxuryClinicCashierApp.gold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.print, color: Colors.black),
                  label: Text('إتمام البيع وطباعة الفاتورة (${cart.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
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
// 2. شاشة المخزن
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
    final imgCtrl = TextEditingController(text: existing?.imageUrl ?? '');
    bool isService = existing?.isService ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: LuxuryClinicCashierApp.darkCard,
            title: Text(existing == null ? 'إضافة صنف جديد' : 'تعديل الصنف', style: const TextStyle(color: LuxuryClinicCashierApp.gold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الصنف أو الخدمة')),
                  const SizedBox(height: 8),
                  TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر (د.ع)')),
                  const SizedBox(height: 8),
                  TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'رابط صورة المادة (URL)')),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('هل هي خدمة طبية؟'),
                    value: isService,
                    activeColor: LuxuryClinicCashierApp.gold,
                    onChanged: (val) => setDlg(() => isService = val ?? false),
                  ),
                  if (!isService)
                    TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الكمية المتوفرة')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold, foregroundColor: Colors.black),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text) ?? 0.0;
                  final stock = int.tryParse(stockCtrl.text) ?? 0;

                  if (name.isNotEmpty) {
                    setState(() {
                      if (existing != null) {
                        existing.name = name;
                        existing.price = price;
                        existing.stock = stock;
                        existing.imageUrl = imgCtrl.text.trim();
                      } else {
                        AppState.products.add(Product(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          price: price,
                          stock: stock,
                          isService: isService,
                          imageUrl: imgCtrl.text.trim(),
                        ));
                      }
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('حفظ'),
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
        title: const Text('إدارة المخزون والمواد'),
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
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LuxuryClinicCashierApp.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LuxuryClinicCashierApp.darkBorder),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.white10,
                    child: p.imageUrl.isNotEmpty
                        ? Image.network(p.imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))
                        : Icon(p.isService ? Icons.medical_services : Icons.medication, color: LuxuryClinicCashierApp.gold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 3),
                      Text('${p.price.toInt()} د.ع', style: const TextStyle(color: LuxuryClinicCashierApp.gold, fontWeight: FontWeight.bold)),
                      if (!p.isService)
                        Text('المتوفر: ${p.stock}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: () => _openProductDialog(existing: p)),
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
// 3. شاشة المشتريات
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
            title: const Text('تسجيل فاتورة شراء ومذخر', style: TextStyle(color: LuxuryClinicCashierApp.gold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Product>(
                    value: selectedProduct,
                    dropdownColor: LuxuryClinicCashierApp.darkCard,
                    decoration: const InputDecoration(labelText: 'اختر المادة المشتراة'),
                    items: physicalProducts.map((p) {
                      return DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (val) => setDlgState(() => selectedProduct = val),
                  ),
                  TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الكمية المشتراة')),
                  TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تكلفة المفرد (د.ع)')),
                  TextField(controller: supplierCtrl, decoration: const InputDecoration(labelText: 'اسم المذخر أو المورد')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold, foregroundColor: Colors.black),
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
                child: const Text('تسجيل وزيادة المخزون'),
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
                  padding: const EdgeInsets.all(12),
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
                          Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('المذخر: ${item.supplier}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text('الكمية: +${item.qty}', style: const TextStyle(fontSize: 11, color: Colors.greenAccent)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${item.totalCost.toInt()} د.ع', style: const TextStyle(fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold)),
                          Text('${item.date.year}/${item.date.month}/${item.date.day}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
// 4. سجل المبيعات والفواتير
// -------------------------------------------------------------
class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل المبيعات والفواتير')),
      body: AppState.sales.isEmpty
          ? const Center(child: Text('لا توجد مبيعات مسجلة حتى الآن.', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: AppState.sales.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final invoice = AppState.sales[i];
                return Container(
                  padding: const EdgeInsets.all(12),
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
                      'الكاشير: ${invoice.cashierName} (@${invoice.cashierUsername})\nالتاريخ: ${invoice.date.year}/${invoice.date.month}/${invoice.date.day}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.print, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => Directionality(textDirection: TextDirection.rtl, child: ThermalReceiptDialog(invoice: invoice)),
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
// 5. الجرد والإحصائيات الشاملة (للمدير)
// -------------------------------------------------------------
class AdminMonthlyAuditScreen extends StatefulWidget {
  const AdminMonthlyAuditScreen({super.key});

  @override
  State<AdminMonthlyAuditScreen> createState() => _AdminMonthlyAuditScreenState();
}

class _AdminMonthlyAuditScreenState extends State<AdminMonthlyAuditScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  String? selectedUsername;

  @override
  Widget build(BuildContext context) {
    final filteredSales = AppState.sales.where((s) {
      final matchDate = s.date.year == selectedYear && s.date.month == selectedMonth;
      if (selectedUsername == null) return matchDate;
      return matchDate && s.cashierUsername == selectedUsername;
    }).toList();

    final totalRevenue = filteredSales.fold(0.0, (sum, s) => sum + s.totalAmount);
    final totalPurchases = AppState.purchases.fold(0.0, (sum, p) => sum + p.totalCost);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الجرد والإحصائيات الشهرية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts, color: LuxuryClinicCashierApp.gold),
            tooltip: 'إدارة المستخدمين',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: UsersManagementScreen()),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF13151B),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedMonth,
                    dropdownColor: LuxuryClinicCashierApp.darkCard,
                    decoration: const InputDecoration(labelText: 'الشهر'),
                    items: List.generate(12, (i) => i + 1).map((m) {
                      return DropdownMenuItem(value: m, child: Text('شهر $m / $selectedYear'));
                    }).toList(),
                    onChanged: (val) => setState(() => selectedMonth = val ?? DateTime.now().month),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: selectedUsername,
                    dropdownColor: LuxuryClinicCashierApp.darkCard,
                    decoration: const InputDecoration(labelText: 'المستخدم / الكاشير'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('كافة المستخدمين')),
                      ...AppState.users.map((u) => DropdownMenuItem(value: u.username, child: Text(u.fullName))),
                    ],
                    onChanged: (val) => setState(() => selectedUsername = val),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: LuxuryClinicCashierApp.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: LuxuryClinicCashierApp.gold),
                    ),
                    child: Column(
                      children: [
                        const Text('مبيعات الشهر المحدد', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('${totalRevenue.toInt()} د.ع', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: LuxuryClinicCashierApp.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        const Text('إجمالي تكلفة المشتريات', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('${totalPurchases.toInt()} د.ع', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredSales.isEmpty
                ? const Center(child: Text('لا توجد مبيعات في هذا الشهر المحدد.', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    itemCount: filteredSales.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final s = filteredSales[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: LuxuryClinicCashierApp.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: LuxuryClinicCashierApp.darkBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${s.invoiceNumber} — ${s.cashierName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('التاريخ: ${s.date.year}/${s.date.month}/${s.date.day}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                            Text('${s.totalAmount.toInt()} د.ع', style: const TextStyle(color: LuxuryClinicCashierApp.gold, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// الجرد الشخصي للكاشير
// -------------------------------------------------------------
class UserPersonalAuditScreen extends StatefulWidget {
  const UserPersonalAuditScreen({super.key});

  @override
  State<UserPersonalAuditScreen> createState() => _UserPersonalAuditScreenState();
}

class _UserPersonalAuditScreenState extends State<UserPersonalAuditScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final currentUsername = AppState.currentUser?.username ?? "";

    final mySales = AppState.sales.where((s) {
      return s.date.year == selectedYear && s.date.month == selectedMonth && s.cashierUsername == currentUsername;
    }).toList();

    final myTotalRevenue = mySales.fold(0.0, (sum, s) => sum + s.totalAmount);

    return Scaffold(
      appBar: AppBar(title: const Text('جردي الشهري الشخصي')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LuxuryClinicCashierApp.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: LuxuryClinicCashierApp.gold),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('مجموع مبيعاتي للشهر', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${myTotalRevenue.toInt()} د.ع', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('عدد فواتيري', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${mySales.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: mySales.isEmpty
                ? const Center(child: Text('لا توجد مبيعات مسجلة باسمك هذا الشهر.', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    itemCount: mySales.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final s = mySales[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: LuxuryClinicCashierApp.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: LuxuryClinicCashierApp.darkBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${s.totalAmount.toInt()} د.ع', style: const TextStyle(color: LuxuryClinicCashierApp.gold, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// إدارة المستخدمين (للمدير)
// -------------------------------------------------------------
class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  void _openUserDialog({AppUser? userToEdit}) {
    final nameCtrl = TextEditingController(text: userToEdit?.fullName ?? '');
    final userCtrl = TextEditingController(text: userToEdit?.username ?? '');
    final passCtrl = TextEditingController(text: userToEdit?.password ?? '');
    UserRole selectedRole = userToEdit?.role ?? UserRole.cashier;
    final bool isEditing = userToEdit != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: LuxuryClinicCashierApp.darkCard,
            title: Text(isEditing ? 'تعديل المستخدم' : 'إضافة موظف/كاشير', style: const TextStyle(color: LuxuryClinicCashierApp.gold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم الكامل')),
                  const SizedBox(height: 8),
                  TextField(controller: userCtrl, enabled: !isEditing, decoration: const InputDecoration(labelText: 'اسم الدخول (Username)')),
                  const SizedBox(height: 8),
                  TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'الرمز السري')),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    dropdownColor: LuxuryClinicCashierApp.darkCard,
                    decoration: const InputDecoration(labelText: 'الصلاحية'),
                    items: const [
                      DropdownMenuItem(value: UserRole.cashier, child: Text('كاشير / تمريض')),
                      DropdownMenuItem(value: UserRole.admin, child: Text('مدير')),
                    ],
                    onChanged: (val) => setDlg(() => selectedRole = val ?? UserRole.cashier),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold, foregroundColor: Colors.black),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final user = userCtrl.text.trim();
                  final pass = passCtrl.text.trim();

                  if (name.isEmpty || user.isEmpty || pass.isEmpty) return;

                  if (!isEditing && AppState.users.any((u) => u.username.toLowerCase() == user.toLowerCase())) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اسم المستخدم مسجل مسبقاً!')));
                    return;
                  }

                  setState(() {
                    if (isEditing) {
                      userToEdit.fullName = name;
                      userToEdit.password = pass;
                    } else {
                      AppState.users.add(AppUser(username: user, password: pass, fullName: name, role: selectedRole));
                    }
                  });

                  Navigator.pop(ctx);
                },
                child: Text(isEditing ? 'حفظ' : 'إضافة'),
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
        title: const Text('إدارة المستخدمين والكادر'),
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: () => _openUserDialog()),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: AppState.users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final u = AppState.users[i];
          final isCurrentUser = u.username == AppState.currentUser?.username;

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LuxuryClinicCashierApp.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: LuxuryClinicCashierApp.darkBorder),
            ),
            child: ListTile(
              leading: Icon(u.role == UserRole.admin ? Icons.shield : Icons.person, color: LuxuryClinicCashierApp.gold),
              title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('اسم المستخدم: ${u.username} | الرمز: ${u.password}\nالدور: ${u.role == UserRole.admin ? "مدير" : "كاشير"}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: () => _openUserDialog(userToEdit: u)),
                  if (!isCurrentUser)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () {
                        setState(() => AppState.users.removeAt(i));
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// حوار وطباعة الفاتورة الحرارية
// -------------------------------------------------------------
class ThermalReceiptDialog extends StatelessWidget {
  final SaleInvoice invoice;

  const ThermalReceiptDialog({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_hospital, size: 40, color: Colors.black87),
              Text(AppState.storeName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(AppState.storeAddress, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 10)),
              Text('هاتف: ${AppState.storePhone}', style: const TextStyle(color: Colors.black87, fontSize: 11)),
              const Divider(color: Colors.black87),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('فاتورة: ${invoice.invoiceNumber}', style: const TextStyle(color: Colors.black, fontSize: 11)),
                  Text('${invoice.date.year}/${invoice.date.month}/${invoice.date.day}', style: const TextStyle(color: Colors.black, fontSize: 11)),
                ],
              ),
              Align(alignment: Alignment.centerRight, child: Text('الكاشير: ${invoice.cashierName}', style: const TextStyle(color: Colors.black, fontSize: 11))),
              const Divider(color: Colors.black54),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المجموع النهائي:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${invoice.totalAmount.toInt()} د.ع', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                icon: const Icon(Icons.print, size: 16),
                label: const Text('طباعة الفاتورة'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
