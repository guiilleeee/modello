import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow(const WindowOptions(size: Size(1280, 800), minimumSize: Size(1280, 800), center: true,
      backgroundColor: Colors.transparent, skipTaskbar: false, titleBarStyle: TitleBarStyle.hidden, title: 'Nexus POS'),
      () async { await windowManager.show(); await windowManager.focus(); });
  }
  final prefs = await SharedPreferences.getInstance();
  final lc = prefs.getString('language') ?? 'ES';
  final lang = AppLanguage.values.firstWhere((e) => e.code == lc, orElse: () => AppLanguage.es);
  final name = prefs.getString('restaurantName') ?? 'La Taverna del Mar';
  runApp(NexusApp(lang: lang, name: name, prefs: prefs));
}

enum AppLanguage { ca, es, en }
extension AppLanguageMeta on AppLanguage {
  String get code { switch (this) { case AppLanguage.ca: return 'CA'; case AppLanguage.es: return 'ES'; case AppLanguage.en: return 'EN'; } }
  String get label { switch (this) { case AppLanguage.ca: return 'Catala'; case AppLanguage.es: return 'Espanol'; case AppLanguage.en: return 'English'; } }
}

class AppController extends ChangeNotifier {
  AppController(this._lang, this._name, this._prefs);
  AppLanguage _lang; String _name; final SharedPreferences _prefs;
  AppLanguage get language => _lang;
  String get restaurantName => _name;
  void setLanguage(AppLanguage v) { if (_lang == v) return; _lang = v; _prefs.setString('language', v.code); notifyListeners(); }
  void setName(String v) { _name = v; _prefs.setString('restaurantName', v); notifyListeners(); }
}

class C {
  static const bg = Color(0xFFF9F8F6);
  static const surface = Color(0xFFFFFFFF);
  static const warm = Color(0xFFF5F3EF);
  static const border = Color(0xFFD4CFC7);
  static const borderLight = Color(0xFFE8E4DD);
  static const text = Color(0xFF2C2420);
  static const textSec = Color(0xFF6B6158);
  static const textMut = Color(0xFF9C9488);
  static const burg = Color(0xFF722F37);
  static const burgBg = Color(0xFFF5E6E8);
  static const forest = Color(0xFF2D6B3F);
  static const forestBg = Color(0xFFE3F0E6);
  static const navy = Color(0xFF1B3A5C);
  static const navyBg = Color(0xFFE0EAF2);
  static const amber = Color(0xFFB8860B);
  static const amberBg = Color(0xFFFDF3D7);
  static const danger = Color(0xFFC43E3E);
  static const dangerBg = Color(0xFFFCE8E8);
  static const grey = Color(0xFF7A7672);
  static const greyBg = Color(0xFFEDEBE8);
}

class NexusDesktopScrollBehavior extends MaterialScrollBehavior {
  const NexusDesktopScrollBehavior();
  @override Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.stylus, PointerDeviceKind.trackpad};
}

class NexusApp extends StatefulWidget {
  const NexusApp({required this.lang, required this.name, required this.prefs, super.key});
  final AppLanguage lang; final String name; final SharedPreferences prefs;
  @override State<NexusApp> createState() => _NexusAppState();
}
class _NexusAppState extends State<NexusApp> {
  late final AppController _ctrl;
  @override void initState() { super.initState(); _ctrl = AppController(widget.lang, widget.name, widget.prefs); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _ctrl, builder: (ctx, _) => MaterialApp(
      debugShowCheckedModeBanner: false, title: 'Nexus POS', scrollBehavior: const NexusDesktopScrollBehavior(),
      theme: ThemeData(useMaterial3: true, brightness: Brightness.light, scaffoldBackgroundColor: C.bg, fontFamily: 'Inter',
        colorScheme: const ColorScheme.light(surface: C.surface, primary: C.burg, secondary: C.navy, error: C.danger)),
      home: MainShell(ctrl: _ctrl),
    ));
  }
}

// === L10N ===
class T {
  static final Map<String, Map<AppLanguage, String>> _v = {
    'synced': {AppLanguage.ca: 'Sincronitzat', AppLanguage.es: 'Sincronizado', AppLanguage.en: 'Synced'},
    'navLive': {AppLanguage.ca: 'Directe', AppLanguage.es: 'Directo', AppLanguage.en: 'Live'},
    'navFloor': {AppLanguage.ca: 'Sala', AppLanguage.es: 'Sala', AppLanguage.en: 'Floor'},
    'navKitchen': {AppLanguage.ca: 'Cuina', AppLanguage.es: 'Cocina', AppLanguage.en: 'Kitchen'},
    'navProducts': {AppLanguage.ca: 'Productes', AppLanguage.es: 'Productos', AppLanguage.en: 'Products'},
    'navSettings': {AppLanguage.ca: 'Config.', AppLanguage.es: 'Config.', AppLanguage.en: 'Settings'},
    'floorMap': {AppLanguage.ca: 'Mapa de sala', AppLanguage.es: 'Mapa de sala', AppLanguage.en: 'Floor plan'},
    'liveOrders': {AppLanguage.ca: 'Comandes', AppLanguage.es: 'Pedidos', AppLanguage.en: 'Orders'},
    'revenueToday': {AppLanguage.ca: 'Ingressos avui', AppLanguage.es: 'Ingresos hoy', AppLanguage.en: 'Revenue today'},
    'averageTicket': {AppLanguage.ca: 'Tiquet mitja', AppLanguage.es: 'Ticket medio', AppLanguage.en: 'Avg. ticket'},
    'activeTables': {AppLanguage.ca: 'Taules actives', AppLanguage.es: 'Mesas activas', AppLanguage.en: 'Active tables'},
    'averageWait': {AppLanguage.ca: 'Espera mitjana', AppLanguage.es: 'Espera media', AppLanguage.en: 'Avg. wait'},
    'vsYesterday': {AppLanguage.ca: 'vs ahir', AppLanguage.es: 'vs ayer', AppLanguage.en: 'vs yesterday'},
    'coverage': {AppLanguage.ca: 'cobertura', AppLanguage.es: 'cobertura', AppLanguage.en: 'coverage'},
    'improvement': {AppLanguage.ca: 'millora', AppLanguage.es: 'mejora', AppLanguage.en: 'improvement'},
    'stageNew': {AppLanguage.ca: 'Nous', AppLanguage.es: 'Nuevos', AppLanguage.en: 'New'},
    'stageCooking': {AppLanguage.ca: 'Preparant', AppLanguage.es: 'Cocinando', AppLanguage.en: 'Cooking'},
    'stageReady': {AppLanguage.ca: 'Llestos', AppLanguage.es: 'Listos', AppLanguage.en: 'Ready'},
    'table': {AppLanguage.ca: 'Taula', AppLanguage.es: 'Mesa', AppLanguage.en: 'Table'},
    'covers': {AppLanguage.ca: 'pax', AppLanguage.es: 'pax', AppLanguage.en: 'pax'},
    'min': {AppLanguage.ca: 'min', AppLanguage.es: 'min', AppLanguage.en: 'min'},
    'guests': {AppLanguage.ca: 'com.', AppLanguage.es: 'com.', AppLanguage.en: 'guests'},
    'noOrders': {AppLanguage.ca: 'Sense comandes', AppLanguage.es: 'Sin pedidos', AppLanguage.en: 'No orders'},
    'priority': {AppLanguage.ca: 'URGENT', AppLanguage.es: 'URGENTE', AppLanguage.en: 'URGENT'},
    'served': {AppLanguage.ca: 'Servit', AppLanguage.es: 'Servido', AppLanguage.en: 'Served'},
    'newOrder': {AppLanguage.ca: 'Nou Pedido', AppLanguage.es: 'Nuevo Pedido', AppLanguage.en: 'New Order'},
    'free': {AppLanguage.ca: 'Lliure', AppLanguage.es: 'Libre', AppLanguage.en: 'Free'},
    'seated': {AppLanguage.ca: 'Ocupada', AppLanguage.es: 'Ocupada', AppLanguage.en: 'Seated'},
    'serving': {AppLanguage.ca: 'Servint', AppLanguage.es: 'Sirviendo', AppLanguage.en: 'Serving'},
    'paying': {AppLanguage.ca: 'Pagant', AppLanguage.es: 'Pagando', AppLanguage.en: 'Paying'},
    'cleaning': {AppLanguage.ca: 'Netejant', AppLanguage.es: 'Limpiando', AppLanguage.en: 'Cleaning'},
    'entrance': {AppLanguage.ca: 'Entrada', AppLanguage.es: 'Entrada', AppLanguage.en: 'Entrance'},
    'restaurantName': {AppLanguage.ca: 'Nom del restaurant', AppLanguage.es: 'Nombre del restaurante', AppLanguage.en: 'Restaurant name'},
    'language': {AppLanguage.ca: 'Idioma', AppLanguage.es: 'Idioma', AppLanguage.en: 'Language'},
    'general': {AppLanguage.ca: 'General', AppLanguage.es: 'General', AppLanguage.en: 'General'},
    'products': {AppLanguage.ca: 'Productes', AppLanguage.es: 'Productos', AppLanguage.en: 'Products'},
    'createProduct': {AppLanguage.ca: 'Crear producte', AppLanguage.es: 'Crear producto', AppLanguage.en: 'Create product'},
    'addToOrder': {AppLanguage.ca: 'Afegir', AppLanguage.es: 'Anadir', AppLanguage.en: 'Add'},
    'send': {AppLanguage.ca: 'Enviar', AppLanguage.es: 'Enviar', AppLanguage.en: 'Send'},
    'cancel': {AppLanguage.ca: 'CancelÂ·lar', AppLanguage.es: 'Cancelar', AppLanguage.en: 'Cancel'},
    'ticket': {AppLanguage.ca: 'Tiquet', AppLanguage.es: 'Ticket', AppLanguage.en: 'Ticket'},
    'note': {AppLanguage.ca: 'Nota', AppLanguage.es: 'Nota', AppLanguage.en: 'Note'},
    'total': {AppLanguage.ca: 'Total', AppLanguage.es: 'Total', AppLanguage.en: 'Total'},
    'selectTable': {AppLanguage.ca: 'Seleccionar taula', AppLanguage.es: 'Seleccionar mesa', AppLanguage.en: 'Select table'},
  };
  static String t(AppLanguage l, String k) => _v[k]?[l] ?? _v[k]?[AppLanguage.en] ?? k;
}

// === DATA MODELS ===
enum OrderStage { fresh, cooking, ready }
enum TableShape { square, round }
enum FloorStatus { free, seated, serving, paying, cleaning }

class KpiMetric { const KpiMetric({required this.labelKey, required this.value, required this.delta, required this.captionKey, required this.positive, required this.icon, required this.accent, required this.accentBg}); final String labelKey, value, delta, captionKey; final bool positive; final IconData icon; final Color accent, accentBg; }

class FloorTable {
  FloorTable({required this.number, required this.seats, required this.shape, this.status = FloorStatus.free});
  final int number, seats; final TableShape shape; FloorStatus status;
}

class OrderLine { const OrderLine({required this.qty, required this.name, required this.price, this.note}); final int qty; final String name; final double price; final String? note; }

class LiveOrder {
  LiveOrder({required this.id, required this.tableNumber, required this.guests, required this.lines, required this.elapsedMinutes, required this.stage, this.priority = false, this.note});
  final String id; final int tableNumber, guests, elapsedMinutes; final List<OrderLine> lines; final OrderStage stage; final bool priority; final String? note;
  double get total => lines.fold(0.0, (s, l) => s + l.qty * l.price);
  LiveOrder copyWith({OrderStage? stage}) => LiveOrder(id: id, tableNumber: tableNumber, guests: guests, lines: lines, elapsedMinutes: elapsedMinutes, stage: stage ?? this.stage, priority: priority, note: note);
}

class MenuProduct { const MenuProduct({required this.name, required this.price, required this.category}); final String name; final double price; final String category; }

String fmtCur(double v, AppLanguage l) {
  final f = v.toStringAsFixed(2).split('.'); final s = l == AppLanguage.en ? ',' : '.'; final d = l == AppLanguage.en ? '.' : ',';
  final c = f.first.split('').reversed.toList(); final b = StringBuffer();
  for (var i = 0; i < c.length; i++) { if (i > 0 && i % 3 == 0) b.write(s); b.write(c[i]); }
  return '${b.toString().split('').reversed.join()}$d${f.last} â‚¬';
}
String stageLbl(AppLanguage l, OrderStage s) { switch (s) { case OrderStage.fresh: return T.t(l, 'stageNew'); case OrderStage.cooking: return T.t(l, 'stageCooking'); case OrderStage.ready: return T.t(l, 'stageReady'); } }
Color stageCol(OrderStage s) { switch (s) { case OrderStage.fresh: return C.navy; case OrderStage.cooking: return C.amber; case OrderStage.ready: return C.forest; } }
Color stageBg(OrderStage s) { switch (s) { case OrderStage.fresh: return C.navyBg; case OrderStage.cooking: return C.amberBg; case OrderStage.ready: return C.forestBg; } }
String statusLbl(AppLanguage l, FloorStatus s) { switch (s) { case FloorStatus.free: return T.t(l, 'free'); case FloorStatus.seated: return T.t(l, 'seated'); case FloorStatus.serving: return T.t(l, 'serving'); case FloorStatus.paying: return T.t(l, 'paying'); case FloorStatus.cleaning: return T.t(l, 'cleaning'); } }
Color statusCol(FloorStatus s) { switch (s) { case FloorStatus.free: return C.forest; case FloorStatus.seated: return C.navy; case FloorStatus.serving: return C.amber; case FloorStatus.paying: return C.burg; case FloorStatus.cleaning: return C.grey; } }
Color statusBg(FloorStatus s) { switch (s) { case FloorStatus.free: return C.forestBg; case FloorStatus.seated: return C.navyBg; case FloorStatus.serving: return C.amberBg; case FloorStatus.paying: return C.burgBg; case FloorStatus.cleaning: return C.greyBg; } }

// === MOCK DATA ===
List<FloorTable> createTables() => [
  FloorTable(number: 1, seats: 2, shape: TableShape.round, status: FloorStatus.seated),
  FloorTable(number: 2, seats: 4, shape: TableShape.square, status: FloorStatus.free),
  FloorTable(number: 3, seats: 4, shape: TableShape.square, status: FloorStatus.serving),
  FloorTable(number: 4, seats: 2, shape: TableShape.round, status: FloorStatus.paying),
  FloorTable(number: 5, seats: 6, shape: TableShape.square, status: FloorStatus.seated),
  FloorTable(number: 6, seats: 2, shape: TableShape.round, status: FloorStatus.free),
  FloorTable(number: 7, seats: 4, shape: TableShape.square, status: FloorStatus.cleaning),
  FloorTable(number: 8, seats: 8, shape: TableShape.square, status: FloorStatus.seated),
  FloorTable(number: 9, seats: 4, shape: TableShape.round, status: FloorStatus.free),
  FloorTable(number: 10, seats: 2, shape: TableShape.round, status: FloorStatus.serving),
  FloorTable(number: 11, seats: 6, shape: TableShape.square, status: FloorStatus.seated),
  FloorTable(number: 12, seats: 4, shape: TableShape.square, status: FloorStatus.free),
  FloorTable(number: 13, seats: 2, shape: TableShape.round, status: FloorStatus.free),
  FloorTable(number: 14, seats: 4, shape: TableShape.square, status: FloorStatus.paying),
  FloorTable(number: 15, seats: 4, shape: TableShape.square, status: FloorStatus.free),
  FloorTable(number: 16, seats: 6, shape: TableShape.round, status: FloorStatus.seated),
  FloorTable(number: 17, seats: 2, shape: TableShape.round, status: FloorStatus.free),
  FloorTable(number: 18, seats: 4, shape: TableShape.square, status: FloorStatus.serving),
  FloorTable(number: 19, seats: 8, shape: TableShape.square, status: FloorStatus.free),
  FloorTable(number: 20, seats: 2, shape: TableShape.round, status: FloorStatus.cleaning),
];

List<LiveOrder> createOrders() => [
  LiveOrder(id: 'N-1048', tableNumber: 4, guests: 2, elapsedMinutes: 4, stage: OrderStage.fresh, priority: true, note: 'Alergia al gluten', lines: [
    const OrderLine(qty: 2, name: 'Burger trufada', price: 14.50), const OrderLine(qty: 1, name: 'Patatas bravas', price: 6.50), const OrderLine(qty: 2, name: 'IPA artesanal', price: 5.80)]),
  LiveOrder(id: 'N-1049', tableNumber: 11, guests: 6, elapsedMinutes: 9, stage: OrderStage.fresh, lines: [
    const OrderLine(qty: 3, name: 'Tacos cochinita', price: 12.00), const OrderLine(qty: 2, name: 'Ensalada burrata', price: 11.50), const OrderLine(qty: 1, name: 'Ribeye 400g', price: 28.00)]),
  LiveOrder(id: 'N-1050', tableNumber: 2, guests: 4, elapsedMinutes: 12, stage: OrderStage.cooking, note: 'Sin cebolla mesa entera', lines: [
    const OrderLine(qty: 2, name: 'Risotto setas', price: 15.00), const OrderLine(qty: 1, name: 'Pulpo brasa', price: 18.50), const OrderLine(qty: 2, name: 'Limonada romero', price: 4.50)]),
  LiveOrder(id: 'N-1051', tableNumber: 9, guests: 4, elapsedMinutes: 18, stage: OrderStage.cooking, priority: true, lines: [
    const OrderLine(qty: 1, name: 'Arroz meloso gamba', price: 19.00), const OrderLine(qty: 2, name: 'Croquetas jamon', price: 9.50, note: 'Extra salsa'), const OrderLine(qty: 1, name: 'Tarta manzana', price: 7.50)]),
  LiveOrder(id: 'N-1052', tableNumber: 16, guests: 6, elapsedMinutes: 15, stage: OrderStage.cooking, lines: [
    const OrderLine(qty: 2, name: 'Pescado del dia', price: 22.00), const OrderLine(qty: 2, name: 'Steak tartar', price: 17.50), const OrderLine(qty: 1, name: 'Verduras asadas', price: 9.00)]),
  LiveOrder(id: 'N-1053', tableNumber: 7, guests: 4, elapsedMinutes: 21, stage: OrderStage.ready, lines: [
    const OrderLine(qty: 2, name: 'Canelones rustido', price: 13.00), const OrderLine(qty: 1, name: 'Brioche costilla', price: 14.50), const OrderLine(qty: 2, name: 'Cafe frio', price: 3.50)]),
  LiveOrder(id: 'N-1054', tableNumber: 18, guests: 4, elapsedMinutes: 24, stage: OrderStage.ready, priority: true, note: 'Cumpleanos - postre con vela', lines: [
    const OrderLine(qty: 1, name: 'Lubina a la sal', price: 26.00), const OrderLine(qty: 2, name: 'Alcachofas confitadas', price: 11.00), const OrderLine(qty: 2, name: 'Cava brut', price: 6.50)]),
];

const menuProducts = [
  MenuProduct(name: 'Agua mineral', price: 2.50, category: 'Bebidas'), MenuProduct(name: 'Coca-Cola', price: 3.00, category: 'Bebidas'),
  MenuProduct(name: 'Copa vino tinto', price: 5.50, category: 'Bebidas'), MenuProduct(name: 'Copa vino blanco', price: 5.50, category: 'Bebidas'),
  MenuProduct(name: 'Cerveza artesanal', price: 5.80, category: 'Bebidas'), MenuProduct(name: 'Limonada romero', price: 4.50, category: 'Bebidas'),
  MenuProduct(name: 'Cafe solo', price: 1.80, category: 'Bebidas'), MenuProduct(name: 'Cafe con leche', price: 2.20, category: 'Bebidas'),
  MenuProduct(name: 'Patatas bravas', price: 6.50, category: 'Entrantes'), MenuProduct(name: 'Croquetas jamon', price: 9.50, category: 'Entrantes'),
  MenuProduct(name: 'Ensalada burrata', price: 11.50, category: 'Entrantes'), MenuProduct(name: 'Gazpacho', price: 7.00, category: 'Entrantes'),
  MenuProduct(name: 'Pan con tomate', price: 4.00, category: 'Entrantes'), MenuProduct(name: 'Pulpo brasa', price: 18.50, category: 'Entrantes'),
  MenuProduct(name: 'Risotto setas', price: 15.00, category: 'Primeros'), MenuProduct(name: 'Arroz meloso gamba', price: 19.00, category: 'Primeros'),
  MenuProduct(name: 'Canelones rustido', price: 13.00, category: 'Primeros'), MenuProduct(name: 'Sopa de cebolla', price: 8.50, category: 'Primeros'),
  MenuProduct(name: 'Burger trufada', price: 14.50, category: 'Segundos'), MenuProduct(name: 'Ribeye 400g', price: 28.00, category: 'Segundos'),
  MenuProduct(name: 'Lubina a la sal', price: 26.00, category: 'Segundos'), MenuProduct(name: 'Pescado del dia', price: 22.00, category: 'Segundos'),
  MenuProduct(name: 'Steak tartar', price: 17.50, category: 'Segundos'), MenuProduct(name: 'Pollo de corral', price: 16.00, category: 'Segundos'),
  MenuProduct(name: 'Tarta manzana', price: 7.50, category: 'Postres'), MenuProduct(name: 'Crema catalana', price: 6.50, category: 'Postres'),
  MenuProduct(name: 'Coulant chocolate', price: 8.00, category: 'Postres'), MenuProduct(name: 'Sorbete limon', price: 5.00, category: 'Postres'),
];
final menuCategories = menuProducts.map((p) => p.category).toSet().toList();


// === MAIN SHELL & NAVIGATION ===
class MainShell extends StatefulWidget {
  const MainShell({required this.ctrl, super.key});
  final AppController ctrl;
  @override State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  late List<LiveOrder> _orders;
  late List<FloorTable> _tables;
  int _nav = 0;
  bool _showPOS = false;

  @override void initState() { super.initState(); _orders = createOrders(); _tables = createTables(); }

  void _moveOrder(LiveOrder o, OrderStage s) { setState(() { final i = _orders.indexWhere((x) => x.id == o.id); if (i != -1) _orders[i] = _orders[i].copyWith(stage: s); }); }
  void _changeTableStatus(int idx, FloorStatus s) { setState(() => _tables[idx].status = s); }
  void _addOrder(LiveOrder o) { setState(() => _orders.add(o)); }

  @override Widget build(BuildContext context) {
    return AnimatedBuilder(animation: widget.ctrl, builder: (ctx, _) {
      final l = widget.ctrl.language;
      return Stack(children: [
        Scaffold(backgroundColor: C.bg, body: Column(children: [
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) const SizedBox(height: 32, child: WindowCaption(brightness: Brightness.light, backgroundColor: Colors.transparent)),
          Expanded(child: Row(children: [
            _Rail(nav: _nav, lang: l, onTap: (v) => setState(() => _nav = v)),
            Container(width: 1, color: C.border),
            Expanded(child: Column(children: [
              _TopBar(ctrl: widget.ctrl, onNewOrder: () => setState(() => _showPOS = true)),
              Container(height: 1, color: C.border),
              Expanded(child: IndexedStack(index: _nav, children: [
                _LiveScreen(l: l, orders: _orders, onMove: _moveOrder),
                _FloorScreen(l: l, tables: _tables, onStatus: _changeTableStatus),
                _KitchenScreen(l: l, orders: _orders, onMove: _moveOrder),
                _ProductsScreen(l: l),
                _SettingsScreen(ctrl: widget.ctrl),
              ])),
            ])),
          ])),
        ])),
        if (_showPOS) _POSWizard(l: l, tables: _tables, onClose: () => setState(() => _showPOS = false), onSend: (o) { _addOrder(o); setState(() => _showPOS = false); }),
      ]);
    });
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.nav, required this.lang, required this.onTap});
  final int nav; final AppLanguage lang; final ValueChanged<int> onTap;
  @override Widget build(BuildContext context) {
    final items = [(Icons.dashboard_outlined, 'navLive'), (Icons.map_outlined, 'navFloor'), (Icons.restaurant_outlined, 'navKitchen'), (Icons.inventory_2_outlined, 'navProducts'), (Icons.settings_outlined, 'navSettings')];
    return Container(width: 76, color: C.surface, padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        for (var i = 0; i < items.length; i++) ...[
          _RailBtn(icon: items[i].$1, label: T.t(lang, items[i].$2), sel: nav == i, onTap: () => onTap(i)),
          if (i < items.length - 1) const SizedBox(height: 2),
          if (i == 2) const Spacer(),
        ]]));
  }
}

class _RailBtn extends StatelessWidget {
  const _RailBtn({required this.icon, required this.label, required this.sel, required this.onTap});
  final IconData icon; final String label; final bool sel; final VoidCallback onTap;
  @override Widget build(BuildContext context) {
    return InkWell(borderRadius: BorderRadius.circular(8), onTap: onTap,
      child: Container(width: 64, padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(color: sel ? C.burgBg : Colors.transparent, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: sel ? C.burg.withValues(alpha: 0.25) : Colors.transparent)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20, color: sel ? C.burg : C.textMut),
          const SizedBox(height: 3),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: sel ? C.burg : C.textMut, fontSize: 9.5, fontWeight: FontWeight.w600))])));
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.ctrl, required this.onNewOrder});
  final AppController ctrl; final VoidCallback onNewOrder;
  @override Widget build(BuildContext context) {
    final l = ctrl.language;
    return Container(height: 56, color: C.surface, padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(children: [
        Container(width: 30, height: 30, decoration: BoxDecoration(color: C.burg, borderRadius: BorderRadius.circular(6)),
          child: const Center(child: Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)))),
        const SizedBox(width: 10),
        Text(ctrl.restaurantName, style: const TextStyle(color: C.text, fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(width: 10),
        Container(width: 6, height: 6, decoration: const BoxDecoration(color: C.forest, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(T.t(l, 'synced'), style: const TextStyle(color: C.textMut, fontSize: 10, fontWeight: FontWeight.w500)),
        const Spacer(),
        _Btn(label: '+ ${T.t(l, 'newOrder')}', color: C.burg, onTap: onNewOrder),
        const SizedBox(width: 12),
        _LangSwitch(lang: l, onChanged: ctrl.setLanguage),
      ]));
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.color, required this.onTap});
  final String label; final Color color; final VoidCallback onTap;
  @override Widget build(BuildContext context) {
    return InkWell(borderRadius: BorderRadius.circular(6), onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))));
  }
}

class _LangSwitch extends StatelessWidget {
  const _LangSwitch({required this.lang, required this.onChanged});
  final AppLanguage lang; final ValueChanged<AppLanguage> onChanged;
  @override Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: C.warm, borderRadius: BorderRadius.circular(6), border: Border.all(color: C.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: AppLanguage.values.map((item) {
        final sel = item == lang;
        return InkWell(borderRadius: BorderRadius.circular(4), onTap: () => onChanged(item),
          child: Container(width: 34, height: 26, alignment: Alignment.center,
            decoration: BoxDecoration(color: sel ? C.surface : Colors.transparent, borderRadius: BorderRadius.circular(4), border: Border.all(color: sel ? C.border : Colors.transparent)),
            child: Text(item.code, style: TextStyle(color: sel ? C.text : C.textMut, fontWeight: FontWeight.w700, fontSize: 10))));
      }).toList()));
  }
}

// === LIVE SCREEN ===
class _LiveScreen extends StatelessWidget {
  const _LiveScreen({required this.l, required this.orders, required this.onMove});
  final AppLanguage l; final List<LiveOrder> orders; final void Function(LiveOrder, OrderStage) onMove;
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      _KpiStrip(l: l), const SizedBox(height: 12),
      Expanded(child: _Kanban(l: l, orders: orders, onMove: onMove)),
    ]));
  }
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.l});
  final AppLanguage l;
  @override Widget build(BuildContext context) {
    final m = [
      KpiMetric(labelKey: 'revenueToday', value: fmtCur(1452.80, l), delta: '+12.4%', captionKey: 'vsYesterday', positive: true, icon: Icons.trending_up, accent: C.forest, accentBg: C.forestBg),
      KpiMetric(labelKey: 'averageTicket', value: fmtCur(38.70, l), delta: '+3.1%', captionKey: 'vsYesterday', positive: true, icon: Icons.receipt_long, accent: C.burg, accentBg: C.burgBg),
      const KpiMetric(labelKey: 'activeTables', value: '18 / 24', delta: '+4', captionKey: 'coverage', positive: true, icon: Icons.table_restaurant, accent: C.navy, accentBg: C.navyBg),
      const KpiMetric(labelKey: 'averageWait', value: '11 min', delta: '-2 min', captionKey: 'improvement', positive: true, icon: Icons.timer_outlined, accent: C.amber, accentBg: C.amberBg),
    ];
    return Row(children: [for (var i = 0; i < m.length; i++) ...[
      Expanded(child: _KpiCard(m: m[i], l: l)), if (i < m.length - 1) const SizedBox(width: 10)]]);
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.m, required this.l});
  final KpiMetric m; final AppLanguage l;
  @override Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: m.accentBg, borderRadius: BorderRadius.circular(6)),
            child: Icon(m.icon, size: 16, color: m.accent)),
          const SizedBox(width: 8),
          Expanded(child: Text(T.t(l, m.labelKey), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.textSec, fontSize: 11, fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 10),
        Text(m.value, style: const TextStyle(color: C.text, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: m.positive ? C.forestBg : C.dangerBg, borderRadius: BorderRadius.circular(4)),
            child: Text(m.delta, style: TextStyle(color: m.positive ? C.forest : C.danger, fontSize: 10, fontWeight: FontWeight.w700))),
          const SizedBox(width: 5),
          Expanded(child: Text(T.t(l, m.captionKey), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.textMut, fontSize: 10))),
        ]),
      ]));
  }
}


// === FLOOR PLAN SCREEN ===
class _FloorScreen extends StatelessWidget {
  const _FloorScreen({required this.l, required this.tables, required this.onStatus});
  final AppLanguage l; final List<FloorTable> tables; final void Function(int, FloorStatus) onStatus;
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.map_outlined, size: 18, color: C.textSec), const SizedBox(width: 8),
        Text(T.t(l, 'floorMap'), style: const TextStyle(color: C.text, fontSize: 16, fontWeight: FontWeight.w700)),
        const Spacer(),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: C.amberBg, borderRadius: BorderRadius.circular(4), border: Border.all(color: C.amber.withValues(alpha: 0.3))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.door_front_door_outlined, size: 14, color: C.amber), const SizedBox(width: 4),
            Text(T.t(l, 'entrance'), style: const TextStyle(color: C.amber, fontSize: 11, fontWeight: FontWeight.w700))])),
        const SizedBox(width: 12),
        // Legend
        for (final s in FloorStatus.values) ...[
          Container(width: 10, height: 10, margin: const EdgeInsets.only(left: 8), decoration: BoxDecoration(color: statusCol(s), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(statusLbl(l, s), style: const TextStyle(color: C.textSec, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ]),
      const SizedBox(height: 14),
      Expanded(child: LayoutBuilder(builder: (ctx, c) {
        final cols = c.maxWidth >= 900 ? 8 : c.maxWidth >= 600 ? 6 : 4;
        return GridView.builder(itemCount: tables.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.0),
          itemBuilder: (_, i) => _FloorTile(t: tables[i], l: l, onStatus: (s) => onStatus(i, s)));
      })),
    ]));
  }
}

class _FloorTile extends StatelessWidget {
  const _FloorTile({required this.t, required this.l, required this.onStatus});
  final FloorTable t; final AppLanguage l; final void Function(FloorStatus) onStatus;
  @override Widget build(BuildContext context) {
    final col = statusCol(t.status); final bg = statusBg(t.status);
    final round = t.shape == TableShape.round;
    return InkWell(borderRadius: BorderRadius.circular(round ? 99 : 8),
      onTap: () => showDialog(context: context, builder: (_) => _TableStatusDialog(t: t, l: l, onStatus: onStatus)),
      child: Container(decoration: BoxDecoration(color: bg, shape: round ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: round ? null : BorderRadius.circular(8), border: Border.all(color: col, width: 1.5)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('${t.number}', style: TextStyle(color: col, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text('${t.seats} ${T.t(l, 'covers')}', style: TextStyle(color: col.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(4)),
            child: Text(statusLbl(l, t.status), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))),
        ])));
  }
}

class _TableStatusDialog extends StatelessWidget {
  const _TableStatusDialog({required this.t, required this.l, required this.onStatus});
  final FloorTable t; final AppLanguage l; final void Function(FloorStatus) onStatus;
  @override Widget build(BuildContext context) {
    return AlertDialog(backgroundColor: C.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text('${T.t(l, 'table')} ${t.number}', style: const TextStyle(color: C.text, fontWeight: FontWeight.w800, fontSize: 18)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        for (final s in FloorStatus.values) Padding(padding: const EdgeInsets.only(bottom: 6),
          child: InkWell(borderRadius: BorderRadius.circular(8),
            onTap: () { onStatus(s); Navigator.pop(context); },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: t.status == s ? statusBg(s) : C.warm, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: t.status == s ? statusCol(s) : C.borderLight)),
              child: Row(children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: statusCol(s), borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 10),
                Text(statusLbl(l, s), style: TextStyle(color: t.status == s ? statusCol(s) : C.text, fontSize: 14, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (t.status == s) Icon(Icons.check_circle, size: 18, color: statusCol(s)),
              ]))))
      ]));
  }
}

// === KANBAN (Kitchen + Live) ===
class _KitchenScreen extends StatelessWidget {
  const _KitchenScreen({required this.l, required this.orders, required this.onMove});
  final AppLanguage l; final List<LiveOrder> orders; final void Function(LiveOrder, OrderStage) onMove;
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: _Kanban(l: l, orders: orders, onMove: onMove));
  }
}

class _Kanban extends StatelessWidget {
  const _Kanban({required this.l, required this.orders, required this.onMove});
  final AppLanguage l; final List<LiveOrder> orders; final void Function(LiveOrder, OrderStage) onMove;
  @override Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.receipt_long, size: 16, color: C.textSec), const SizedBox(width: 6),
          Text(T.t(l, 'liveOrders'), style: const TextStyle(color: C.text, fontSize: 15, fontWeight: FontWeight.w700))]),
        const SizedBox(height: 10), Container(height: 1, color: C.border), const SizedBox(height: 10),
        Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final s in OrderStage.values) ...[
            Expanded(child: _OrdCol(stage: s, l: l, orders: orders.where((o) => o.stage == s).toList(), onMove: onMove)),
            if (s != OrderStage.values.last) const SizedBox(width: 8),
          ]]))]));
  }
}

class _OrdCol extends StatelessWidget {
  const _OrdCol({required this.stage, required this.l, required this.orders, required this.onMove});
  final OrderStage stage; final AppLanguage l; final List<LiveOrder> orders; final void Function(LiveOrder, OrderStage) onMove;
  @override Widget build(BuildContext context) {
    final col = stageCol(stage); final bg = stageBg(stage);
    return Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: C.warm, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.borderLight)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Expanded(child: Text(stageLbl(l, stage), style: const TextStyle(color: C.text, fontSize: 13, fontWeight: FontWeight.w700))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4), border: Border.all(color: col.withValues(alpha: 0.2))),
            child: Text('${orders.length}', style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 8),
        Expanded(child: orders.isEmpty
          ? Center(child: Text(T.t(l, 'noOrders'), style: const TextStyle(color: C.textMut, fontSize: 11)))
          : ListView.separated(itemCount: orders.length, separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) => _OrdCard(o: orders[i], l: l, onMove: onMove))),
      ]));
  }
}

class _OrdCard extends StatelessWidget {
  const _OrdCard({required this.o, required this.l, required this.onMove});
  final LiveOrder o; final AppLanguage l; final void Function(LiveOrder, OrderStage) onMove;
  OrderStage? get _prev => o.stage == OrderStage.fresh ? null : o.stage == OrderStage.cooking ? OrderStage.fresh : OrderStage.cooking;
  OrderStage? get _next => o.stage == OrderStage.fresh ? OrderStage.cooking : o.stage == OrderStage.cooking ? OrderStage.ready : null;
  @override Widget build(BuildContext context) {
    final col = stageCol(o.stage);
    return Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: o.priority ? C.danger : C.border, width: o.priority ? 1.5 : 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('${T.t(l, 'table')} ${o.tableNumber}', style: const TextStyle(color: C.text, fontSize: 13, fontWeight: FontWeight.w800)),
          const Spacer(),
          if (o.priority) Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(color: C.danger, borderRadius: BorderRadius.circular(3)),
            child: Text(T.t(l, 'priority'), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800))),
          Text(o.id, style: const TextStyle(color: C.textMut, fontSize: 10)),
        ]),
        if (o.note != null) ...[const SizedBox(height: 5),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: C.dangerBg, borderRadius: BorderRadius.circular(4), border: Border.all(color: C.danger.withValues(alpha: 0.2))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.warning_amber_rounded, size: 12, color: C.danger), const SizedBox(width: 4),
              Flexible(child: Text(o.note!, style: const TextStyle(color: C.danger, fontSize: 10, fontWeight: FontWeight.w600)))]))],
        const SizedBox(height: 6),
        Text('${o.guests} ${T.t(l, 'guests')}', style: const TextStyle(color: C.textSec, fontSize: 10)),
        const SizedBox(height: 5),
        for (final ln in o.lines) Padding(padding: const EdgeInsets.only(bottom: 2),
          child: Row(children: [
            Expanded(child: Text('${ln.qty}x ${ln.name}', style: const TextStyle(color: C.textSec, fontSize: 11, fontWeight: FontWeight.w500))),
            if (ln.note != null) Tooltip(message: ln.note!, child: const Icon(Icons.chat_bubble_outline, size: 10, color: C.amber)),
          ])),
        const SizedBox(height: 6),
        Row(children: [
          Text(fmtCur(o.total, l), style: const TextStyle(color: C.text, fontSize: 12, fontWeight: FontWeight.w800)),
          const Spacer(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: stageBg(o.stage), borderRadius: BorderRadius.circular(4)),
            child: Text('${o.elapsedMinutes} min', style: TextStyle(color: col, fontSize: 9, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 8), Container(height: 1, color: C.borderLight), const SizedBox(height: 6),
        Row(children: [
          if (_prev != null) ...[Expanded(child: _SmBtn(label: 'â† ${stageLbl(l, _prev!)}', col: C.textSec, bg: C.warm, onTap: () => onMove(o, _prev!))), const SizedBox(width: 4)],
          if (_next != null) Expanded(child: _SmBtn(label: '${stageLbl(l, _next!)} â†’', col: stageCol(_next!), bg: stageBg(_next!), onTap: () => onMove(o, _next!)))
          else Expanded(child: _SmBtn(label: 'âœ“ ${T.t(l, 'served')}', col: C.forest, bg: C.forestBg, onTap: () {})),
        ]),
      ]));
  }
}

class _SmBtn extends StatelessWidget {
  const _SmBtn({required this.label, required this.col, required this.bg, required this.onTap});
  final String label; final Color col, bg; final VoidCallback onTap;
  @override Widget build(BuildContext context) {
    return InkWell(borderRadius: BorderRadius.circular(5), onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 5), alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5), border: Border.all(color: col.withValues(alpha: 0.2))),
        child: Text(label, style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.w700))));
  }
}


// === POS ORDER WIZARD ===
class _POSWizard extends StatefulWidget {
  const _POSWizard({required this.l, required this.tables, required this.onClose, required this.onSend});
  final AppLanguage l; final List<FloorTable> tables; final VoidCallback onClose; final void Function(LiveOrder) onSend;
  @override State<_POSWizard> createState() => _POSWizardState();
}
class _POSWizardState extends State<_POSWizard> {
  String _cat = menuCategories.first;
  final List<OrderLine> _cart = [];
  int _table = 1;
  int _guests = 2;
  final _noteCtrl = TextEditingController();

  void _addItem(MenuProduct p) { setState(() {
    final i = _cart.indexWhere((l) => l.name == p.name);
    if (i >= 0) { _cart[i] = OrderLine(qty: _cart[i].qty + 1, name: _cart[i].name, price: _cart[i].price, note: _cart[i].note); }
    else { _cart.add(OrderLine(qty: 1, name: p.name, price: p.price)); }
  }); }
  void _removeItem(int i) { setState(() { if (_cart[i].qty > 1) { _cart[i] = OrderLine(qty: _cart[i].qty - 1, name: _cart[i].name, price: _cart[i].price); } else { _cart.removeAt(i); } }); }
  double get _total => _cart.fold(0.0, (s, l) => s + l.qty * l.price);

  void _send() {
    if (_cart.isEmpty) return;
    final order = LiveOrder(id: 'N-${1055 + math.Random().nextInt(900)}', tableNumber: _table, guests: _guests,
      lines: List.of(_cart), elapsedMinutes: 0, stage: OrderStage.fresh, note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text);
    widget.onSend(order);
  }

  @override void dispose() { _noteCtrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final l = widget.l;
    return Material(color: Colors.black54,
      child: Center(child: Container(width: 1060, height: 640,
        decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border, width: 2)),
        child: Column(children: [
          // Header
          Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(color: C.burg, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            child: Row(children: [
              const Icon(Icons.point_of_sale, size: 18, color: Colors.white), const SizedBox(width: 8),
              Text(T.t(l, 'newOrder'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              const Spacer(),
              // Table selector
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('${T.t(l, 'table')}:', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  DropdownButton<int>(value: _table, isDense: true, underline: const SizedBox.shrink(), dropdownColor: C.surface,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                    iconEnabledColor: Colors.white70, iconSize: 16,
                    items: widget.tables.map((t) => DropdownMenuItem(value: t.number, child: Text('${t.number}', style: const TextStyle(color: C.text, fontSize: 13, fontWeight: FontWeight.w700)))).toList(),
                    onChanged: (v) => setState(() => _table = v!)),
                ])),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.people_outline, size: 14, color: Colors.white70), const SizedBox(width: 4),
                  DropdownButton<int>(value: _guests, isDense: true, underline: const SizedBox.shrink(), dropdownColor: C.surface,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                    iconEnabledColor: Colors.white70, iconSize: 16,
                    items: [1,2,3,4,5,6,7,8].map((g) => DropdownMenuItem(value: g, child: Text('$g', style: const TextStyle(color: C.text, fontSize: 13, fontWeight: FontWeight.w700)))).toList(),
                    onChanged: (v) => setState(() => _guests = v!)),
                ])),
              const SizedBox(width: 12),
              InkWell(onTap: widget.onClose, child: const Icon(Icons.close, size: 20, color: Colors.white70)),
            ])),
          // Body
          Expanded(child: Row(children: [
            // Categories
            Container(width: 130, color: C.warm, child: Column(children: [
              for (final cat in menuCategories)
                InkWell(onTap: () => setState(() => _cat = cat),
                  child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(color: _cat == cat ? C.surface : Colors.transparent, border: Border(left: BorderSide(color: _cat == cat ? C.burg : Colors.transparent, width: 3), bottom: const BorderSide(color: C.borderLight))),
                    child: Text(cat, style: TextStyle(color: _cat == cat ? C.burg : C.textSec, fontSize: 13, fontWeight: FontWeight.w600)))),
            ])),
            Container(width: 1, color: C.border),
            // Product grid
            Expanded(child: Padding(padding: const EdgeInsets.all(12),
              child: GridView.count(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.8,
                children: menuProducts.where((p) => p.category == _cat).map((p) =>
                  InkWell(borderRadius: BorderRadius.circular(8), onTap: () => _addItem(p),
                    child: Container(padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: C.warm, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.border)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.text, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(fmtCur(p.price, l), style: const TextStyle(color: C.burg, fontSize: 13, fontWeight: FontWeight.w800)),
                      ])))).toList()))),
            Container(width: 1, color: C.border),
            // Cart / Ticket
            SizedBox(width: 280, child: Column(children: [
              Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.border))),
                child: Row(children: [const Icon(Icons.receipt, size: 16, color: C.burg), const SizedBox(width: 6),
                  Text(T.t(l, 'ticket'), style: const TextStyle(color: C.text, fontSize: 14, fontWeight: FontWeight.w700)),
                  const Spacer(), Text('${_cart.length} items', style: const TextStyle(color: C.textMut, fontSize: 11))])),
              Expanded(child: _cart.isEmpty
                ? const Center(child: Text('â€”', style: TextStyle(color: C.textMut, fontSize: 20)))
                : ListView.builder(padding: const EdgeInsets.all(8), itemCount: _cart.length, itemBuilder: (_, i) {
                    final ln = _cart[i];
                    return Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: C.warm, borderRadius: BorderRadius.circular(6)),
                      child: Row(children: [
                        InkWell(onTap: () => _removeItem(i), child: Container(width: 22, height: 22, decoration: BoxDecoration(color: C.dangerBg, borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.remove, size: 14, color: C.danger))),
                        const SizedBox(width: 6),
                        Text('${ln.qty}', style: const TextStyle(color: C.text, fontSize: 13, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 6),
                        InkWell(onTap: () => _addItem(MenuProduct(name: ln.name, price: ln.price, category: '')),
                          child: Container(width: 22, height: 22, decoration: BoxDecoration(color: C.forestBg, borderRadius: BorderRadius.circular(4)),
                            child: const Icon(Icons.add, size: 14, color: C.forest))),
                        const SizedBox(width: 8),
                        Expanded(child: Text(ln.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.text, fontSize: 11, fontWeight: FontWeight.w500))),
                        Text(fmtCur(ln.qty * ln.price, l), style: const TextStyle(color: C.textSec, fontSize: 11, fontWeight: FontWeight.w700)),
                      ]));
                  })),
              // Note input
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.borderLight))),
                child: TextField(controller: _noteCtrl, style: const TextStyle(fontSize: 12, color: C.text),
                  decoration: InputDecoration(hintText: '${T.t(l, 'note')}...', hintStyle: const TextStyle(color: C.textMut, fontSize: 12),
                    prefixIcon: const Icon(Icons.note_alt_outlined, size: 16, color: C.textMut), isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8), border: InputBorder.none))),
              // Total + Send
              Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.border))),
                child: Column(children: [
                  Row(children: [Text(T.t(l, 'total'), style: const TextStyle(color: C.textSec, fontSize: 13, fontWeight: FontWeight.w600)),
                    const Spacer(), Text(fmtCur(_total, l), style: const TextStyle(color: C.text, fontSize: 18, fontWeight: FontWeight.w900))]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: InkWell(onTap: widget.onClose, borderRadius: BorderRadius.circular(6),
                      child: Container(padding: const EdgeInsets.symmetric(vertical: 10), alignment: Alignment.center,
                        decoration: BoxDecoration(color: C.warm, borderRadius: BorderRadius.circular(6), border: Border.all(color: C.border)),
                        child: Text(T.t(l, 'cancel'), style: const TextStyle(color: C.textSec, fontSize: 12, fontWeight: FontWeight.w700))))),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: InkWell(onTap: _send, borderRadius: BorderRadius.circular(6),
                      child: Container(padding: const EdgeInsets.symmetric(vertical: 10), alignment: Alignment.center,
                        decoration: BoxDecoration(color: _cart.isEmpty ? C.textMut : C.forest, borderRadius: BorderRadius.circular(6)),
                        child: Text(T.t(l, 'send'), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800))))),
                  ]),
                ])),
            ])),
          ])),
        ]))));
  }
}

// === PRODUCTS SCREEN ===
class _ProductsScreen extends StatelessWidget {
  const _ProductsScreen({required this.l});
  final AppLanguage l;
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.inventory_2_outlined, size: 18, color: C.textSec), const SizedBox(width: 8),
        Text(T.t(l, 'products'), style: const TextStyle(color: C.text, fontSize: 16, fontWeight: FontWeight.w700)),
        const Spacer(),
        _Btn(label: '+ ${T.t(l, 'createProduct')}', color: C.burg, onTap: () {}),
      ]),
      const SizedBox(height: 12),
      Expanded(child: Container(decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.border)),
        child: Column(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: const BoxDecoration(color: C.warm, borderRadius: BorderRadius.vertical(top: Radius.circular(7))),
            child: const Row(children: [
              Expanded(flex: 3, child: Text('Nombre', style: TextStyle(color: C.textSec, fontSize: 11, fontWeight: FontWeight.w700))),
              Expanded(flex: 2, child: Text('Categoria', style: TextStyle(color: C.textSec, fontSize: 11, fontWeight: FontWeight.w700))),
              SizedBox(width: 80, child: Text('Precio', textAlign: TextAlign.right, style: TextStyle(color: C.textSec, fontSize: 11, fontWeight: FontWeight.w700))),
            ])),
          Expanded(child: ListView.separated(itemCount: menuProducts.length, separatorBuilder: (_, __) => const Divider(height: 1, color: C.borderLight),
            itemBuilder: (_, i) {
              final p = menuProducts[i];
              return Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(children: [
                  Expanded(flex: 3, child: Text(p.name, style: const TextStyle(color: C.text, fontSize: 13, fontWeight: FontWeight.w500))),
                  Expanded(flex: 2, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: C.warm, borderRadius: BorderRadius.circular(4)),
                    child: Text(p.category, style: const TextStyle(color: C.textSec, fontSize: 10, fontWeight: FontWeight.w600)))),
                  SizedBox(width: 80, child: Text(fmtCur(p.price, l), textAlign: TextAlign.right, style: const TextStyle(color: C.burg, fontSize: 13, fontWeight: FontWeight.w700))),
                ]));
            })),
        ]))),
    ]));
  }
}

// === SETTINGS SCREEN ===
class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen({required this.ctrl});
  final AppController ctrl;
  @override State<_SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<_SettingsScreen> {
  late final TextEditingController _nc;
  @override void initState() { super.initState(); _nc = TextEditingController(text: widget.ctrl.restaurantName); }
  @override void dispose() { _nc.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final l = widget.ctrl.language;
    return Padding(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(T.t(l, 'navSettings'), style: const TextStyle(color: C.text, fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 20),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(T.t(l, 'general'), style: const TextStyle(color: C.text, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Text(T.t(l, 'restaurantName'), style: const TextStyle(color: C.textSec, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SizedBox(width: 380, child: TextField(controller: _nc, onChanged: widget.ctrl.setName,
            style: const TextStyle(color: C.text, fontSize: 14),
            decoration: InputDecoration(filled: true, fillColor: C.warm, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: C.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: C.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: C.burg, width: 1.5))))),
        ])),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: C.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: C.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(T.t(l, 'language'), style: const TextStyle(color: C.text, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (final item in AppLanguage.values)
            Padding(padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(borderRadius: BorderRadius.circular(6), onTap: () => widget.ctrl.setLanguage(item),
                child: Container(width: 380, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: item == l ? C.burgBg : C.warm, borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: item == l ? C.burg.withValues(alpha: 0.3) : C.borderLight)),
                  child: Row(children: [
                    Icon(item == l ? Icons.radio_button_checked : Icons.radio_button_off, size: 16, color: item == l ? C.burg : C.textMut),
                    const SizedBox(width: 8),
                    Text(item.label, style: TextStyle(color: item == l ? C.burg : C.text, fontSize: 13, fontWeight: FontWeight.w600)),
                  ])))),
        ])),
    ])));
  }
}

