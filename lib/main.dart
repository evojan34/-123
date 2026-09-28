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
  double price; // د.ع
  int stock;
  final int minStock;
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

class AppState {
  static String storeName = "عيادة ومستلزمات التمريض المتنقلة";
  static String storePhone = "0770 123 4567";
  static String storeAddress = "العراق - خدمة الرعاية الطبية والتمريض المنزلي";

  static AppUser? currentUser;
  static List<AppUser> users = [];

  static bool get hasAdmin => users.any((u) => u.role == UserRole.admin);

  static List<Product> products = [
    Product(id: "1", name: "محلول ملحي معقم (Saline 500ml)", price: 3000, stock: 20, minStock: 5),
    Product(id: "2", name: "كانيولا وريدية معقمة قياس 20G", price: 1000, stock: 12, minStock: 5),
    Product(id: "3", name: "شاش طبي وبلاستر معقم", price: 2500, stock: 25, minStock: 5),
    Product(id: "4", name: "أنبوب قسطرة بولية سيليكون", price: 9000, stock: 4, minStock: 3),
    Product(id: "5", name: "جهاز قياس ضغط إلكتروني", price: 35000, stock: 5, minStock: 2),
    Product(id: "6", name: "خدمة: إعطاء حقنة وريدية/عضلية", price: 10000, isService: true),
    Product(id: "7", name: "خدمة: تضميد وتعقيم جروح عميقة", price: 20000, isService: true),
    Product(id: "8", name: "خدمة: تركيب قسطرة بولية مع تعقيم", price: 25000, isService: true),
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
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: AppState.hasAdmin ? const LoginScreen() : const InitialAdminSetupScreen(),
      ),
    );
  }
}

// -------------------------------------------------------------
// شاشة تأسيس حساب المدير العام
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
  String? _error;

  void _saveAdmin() {
    final name = _nameCtrl.text.trim();
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final confirmPass = _confirmPassCtrl.text.trim();

    if (name.isEmpty || user.isEmpty || pass.isEmpty) {
      setState(() => _error = "يرجى ملء جميع الحقول");
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Directionality(
          textDirection: TextDirection.rtl,
          child: MainNavigationScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
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
                const Text(
                  'تأسيس حساب المدير العام',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold),
                ),
                const Text(
                  'أدخل بياناتك الرئيسية كمدير للنظام للمرة الأولى',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'الاسم الكامل للمدير', prefixIcon: Icon(Icons.badge)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(labelText: 'اسم المستخدم (Username)', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'الرمز السري الخاص', prefixIcon: Icon(Icons.lock)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPassCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'تأكيد الرمز السري', prefixIcon: Icon(Icons.lock_outline)),
                ),
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
                  child: const Text('حفظ والدخول إلى البرنامج', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
// شاشة تسجيل الدخول
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
      (u) => u.username == username && u.password == password,
      orElse: () => AppUser(username: "", password: "", fullName: "", role: UserRole.cashier),
    );

    if (matched.username.isNotEmpty) {
      AppState.currentUser = matched;
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
        _errorMessage = "اسم المستخدم أو الرمز السري غير صحيح!";
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
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_hospital, size: 55, color: LuxuryClinicCashierApp.gold),
                const SizedBox(height: 12),
                const Text(
                  'نظام الكاشير التمريضي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold),
                ),
                const Text('تسجيل الدخول (المدير أو المستخدمين)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 24),
                TextField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(labelText: 'اسم المستخدم', prefixIcon: Icon(Icons.person, color: LuxuryClinicCashierApp.gold)),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'الرمز السري', prefixIcon: Icon(Icons.lock, color: LuxuryClinicCashierApp.gold)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// شاشة التنقل الرئيسية
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
      if (isAdmin) const PurchasesScreen(),
      const SalesHistoryScreen(),
      if (isAdmin) const AdminMonthlyAuditScreen() else const UserPersonalAuditScreen(),
      if (isAdmin) const AnalyticsScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'الكاشير'),
      const BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'المخزون'),
      if (isAdmin) const BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'المشتريات'),
      const BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'المبيعات'),
      BottomNavigationBarItem(
        icon: const Icon(Icons.assessment),
        label: isAdmin ? 'جرد الموظفين' : 'جردي الشهري',
      ),
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
// شاشة إدارة المستخدمين
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
            title: Text(isEditing ? 'تعديل المستخدم' : 'إضافة مستخدم جديد',
                style: const TextStyle(color: LuxuryClinicCashierApp.gold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم الكامل')),
                  const SizedBox(height: 8),
                  TextField(
                    controller: userCtrl,
                    enabled: !isEditing,
                    decoration: const InputDecoration(labelText: 'اسم الدخول (Username)'),
                  ),
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
                style: ElevatedButton.styleFrom(backgroundColor: LuxuryClinicCashierApp.gold),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final user = userCtrl.text.trim();
                  final pass = passCtrl.text.trim();

                  if (name.isEmpty || user.isEmpty || pass.isEmpty) return;

                  if (!isEditing && AppState.users.any((u) => u.username.toLowerCase() == user.toLowerCase())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('اسم المستخدم مسجل مسبقاً!')),
                    );
                    return;
                  }

                  setState(() {
                    if (isEditing) {
                      userToEdit.fullName = name;
                      userToEdit.password = pass;
                    } else {
                      AppState.users.add(AppUser(
                        username: user,
                        password: pass,
                        fullName: name,
                        role: selectedRole,
                      ));
                    }
                  });
                  Navigator.pop(ctx);
                },
                child: Text(isEditing ? 'حفظ التعديل' : 'إضافة', style: const TextStyle(color: Colors.black)),
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
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'إضافة مستخدم جديد',
            onPressed: () => _openUserDialog(),
          ),
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
              leading: CircleAvatar(
                backgroundColor: u.role == UserRole.admin ? Colors.redAccent.withOpacity(0.2) : LuxuryClinicCashierApp.gold.withOpacity(0.2),
                child: Icon(
                  u.role == UserRole.admin ? Icons.shield : Icons.person,
                  color: u.role == UserRole.admin ? Colors.redAccent : LuxuryClinicCashierApp.gold,
                ),
              ),
              title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'اسم المستخدم: ${u.username} | الرمز: ${u.password}\nالصلاحية: ${u.role == UserRole.admin ? "مدير" : "كاشير"}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () => _openUserDialog(userToEdit: u),
                  ),
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
// الجرد الشهري للمدير
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('الجرد والتقرير الشهري الشامل'),
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
            color: const Color(0xFF16191E),
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
                      ...AppState.users.map((u) {
                        return DropdownMenuItem(value: u.username, child: Text(u.fullName));
                      }),
                    ],
                    onChanged: (val) => setState(() => selectedUsername = val),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LuxuryClinicCashierApp.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LuxuryClinicCashierApp.gold),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('إجمالي مبيعات الشهر', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${totalRevenue.toInt()} د.ع',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold)),
                    ],
                  ),
                  Container(width: 1, height: 40, color: LuxuryClinicCashierApp.darkBorder),
                  Column(
                    children: [
                      const Text('عدد الفواتير الصادرة', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${filteredSales.length}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('تفاصيل فواتير الجرد:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
          ),
          Expanded(
            child: filteredSales.isEmpty
                ? const Center(child: Text('لا توجد مبيعات مسجلة لهذا التحديد.', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                                Text('${s.invoiceNumber} — ${s.cashierName}',
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('التاريخ: ${s.date.year}/${s.date.month}/${s.date.day} - ${s.items.length} مواد',
                                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                            Text('${s.totalAmount.toInt()} د.ع',
                                style: const TextStyle(color: LuxuryClinicCashierApp.gold, fontWeight: FontWeight.bold)),
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
// جرد شهري خاص بالمستخدم الحالي (تم تصحيح القوس هنا)
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
      appBar: AppBar(
        title: const Text('جردي الشهري الشخصي'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF16191E),
            child: DropdownButtonFormField<int>(
              value: selectedMonth,
              dropdownColor: LuxuryClinicCashierApp.darkCard,
              decoration: const InputDecoration(labelText: 'اختر الشهر'),
              items: List.generate(12, (i) => i + 1).map((m) {
                return DropdownMenuItem(value: m, child: Text('شهر $m / $selectedYear'));
              }).toList(), // تم تصحيح القوس هنا
              onChanged: (val) => setState(() => selectedMonth = val ?? DateTime.now().month),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LuxuryClinicCashierApp.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LuxuryClinicCashierApp.gold),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('مجموع مبيعاتي للشهر', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${myTotalRevenue.toInt()} د.ع',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold)),
                    ],
                  ),
                  Container(width: 1, height: 40, color: LuxuryClinicCashierApp.darkBorder),
                  Column(
                    children: [
                      const Text('عدد فواتيري', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${mySales.length}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('سجل فواتيري الشخصية:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
          ),
          Expanded(
            child: mySales.isEmpty
                ? const Center(child: Text('لا توجد مبيعات مسجلة باسمك في هذا الشهر.', style: TextStyle(color: Colors.grey)))
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('التاريخ: ${s.date.year}/${s.date.month}/${s.date.day} (${s.items.length} مواد)',
                                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                            Text('${s.totalAmount.toInt()} د.ع',
                                style: const TextStyle(color: LuxuryClinicCashierApp.gold, fontWeight: FontWeight.bold)),
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
// شاشة البيع والكاشير
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
          content: Text('نفد مخزون "${product.name}"!'),
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
              content: Text('الكمية المطلوبة تتجاوز المخزون المتوفر (${product.stock})'),
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
              'المستخدم الحالي: ${AppState.currentUser?.fullName ?? ""}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'تسجيل الخروج والتبديل',
            onPressed: () {
              AppState.currentUser = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: LoginScreen()),
                ),
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
                hintText: 'بحث في المواد والخدمات...',
                prefixIcon: const Icon(Icons.search, color: LuxuryClinicCashierApp.gold),
                filled: true,
                fillColor: LuxuryClinicCashierApp.darkCard,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
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
                            Expanded(child: Text(item.product.name, style: const TextStyle(fontSize: 12))),
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
                            Text('${item.qty}'),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16, color: LuxuryClinicCashierApp.gold),
                              onPressed: () => _addToCart(item.product),
                            ),
                            SizedBox(
                              width: 75,
                              child: Text('${item.subtotal.toInt()} د.ع', textAlign: TextAlign.end),
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
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold),
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
// إدارة المخزون
// -------------------------------------------------------------
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المخزون والخدمات')),
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
                  child: Icon(p.isService ? Icons.medical_services : Icons.inventory_2, color: LuxuryClinicCashierApp.gold),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('${p.price.toInt()} د.ع', style: const TextStyle(color: LuxuryClinicCashierApp.gold, fontWeight: FontWeight.bold)),
                      if (!p.isService)
                        Text('المتوفر: ${p.stock} (الحد الأدنى: ${p.minStock})',
                            style: TextStyle(fontSize: 12, color: isLowStock ? Colors.redAccent : Colors.grey)),
                    ],
                  ),
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
// المشتريات
// -------------------------------------------------------------
class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل المشتريات')),
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
                          Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('المورد: ${item.supplier} (+${item.qty})', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Text('${item.totalCost.toInt()} د.ع',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: LuxuryClinicCashierApp.gold)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// -------------------------------------------------------------
// سجل المبيعات
// -------------------------------------------------------------
class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل المبيعات')),
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
                      'الكاشير: ${invoice.cashierName} (@${invoice.cashierUsername})\nالتاريخ: ${invoice.date.year}/${invoice.date.month}/${invoice.date.day}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
// الإحصائيات العامة
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

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير والإحصائيات')),
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
              Expanded(child: _kpiCard('الفواتير الكلية', '${AppState.sales.length}', Icons.receipt, Colors.lightBlueAccent)),
              const SizedBox(width: 10),
              Expanded(child: _kpiCard('عدد المستخدمين', '${AppState.users.length}', Icons.people, Colors.purpleAccent)),
            ],
          ),
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
// حوار وطباعة الفاتورة الحرارية
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
        width: 320,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_hospital, size: 40, color: Colors.black87),
              Text(
                AppState.storeName,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
              ),
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
              Align(
                alignment: Alignment.centerRight,
                child: Text('الكاشير: ${invoice.cashierName}', style: const TextStyle(color: Colors.black, fontSize: 11)),
              ),
              const Divider(color: Colors.black54),
              ...invoice.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${item.product.name} (x${item.qty})', style: const TextStyle(color: Colors.black, fontSize: 11))),
                        Text('${item.subtotal.toInt()} د.ع', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      ],
                    ),
                  )),
              const Divider(color: Colors.black87),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المجموع الكلي:', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('${invoice.totalAmount.toInt()} د.ع', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                icon: const Icon(Icons.print, size: 16),
                label: const Text('طباعة Bluetooth'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
