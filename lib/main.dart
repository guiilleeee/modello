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
    windowManager.waitUntilReadyToShow(const WindowOptions(
      size: Size(1280, 800), minimumSize: Size(1280, 800), center: true,
      backgroundColor: Colors.transparent, skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden, title: 'Nexus',
    ), () async { await windowManager.show(); await windowManager.focus(); });
  }
  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('language') ?? 'ES';
  final lang = AppLanguage.values.firstWhere((e) => e.code == langCode, orElse: () => AppLanguage.es);
  final name = prefs.getString('restaurantName') ?? 'Nexus Restaurant';
  runApp(NexusApp(initialLanguage: lang, initialName: name, prefs: prefs));
}

enum AppLanguage { ca, es, en }
extension AppLanguageMeta on AppLanguage {
  String get code { switch (this) { case AppLanguage.ca: return 'CA'; case AppLanguage.es: return 'ES'; case AppLanguage.en: return 'EN'; } }
  String get label { switch (this) { case AppLanguage.ca: return 'Catala'; case AppLanguage.es: return 'Espanol'; case AppLanguage.en: return 'English'; } }
}

class AppController extends ChangeNotifier {
  AppController(this._language, this._restaurantName, this._prefs);
  AppLanguage _language; String _restaurantName; final SharedPreferences _prefs;
  AppLanguage get language => _language;
  String get restaurantName => _restaurantName;
  void setLanguage(AppLanguage v) { if (_language == v) return; _language = v; _prefs.setString('language', v.code); notifyListeners(); }
  void setRestaurantName(String v) { _restaurantName = v; _prefs.setString('restaurantName', v); notifyListeners(); }
}

class NexusDesktopScrollBehavior extends MaterialScrollBehavior {
  const NexusDesktopScrollBehavior();
  @override Set<PointerDeviceKind> get dragDevices => { PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.stylus, PointerDeviceKind.trackpad };
}

class Nx {
  static const bg = Color(0xFFF5F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF9FAFB);
  static const border = Color(0xFFE5E7EB);
  static const borderLight = Color(0xFFF3F4F6);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);
  static const primary = Color(0xFF2563EB);
  static const primaryBg = Color(0xFFDBEAFE);
  static const success = Color(0xFF059669);
  static const successBg = Color(0xFFD1FAE5);
  static const warning = Color(0xFFD97706);
  static const warningBg = Color(0xFFFEF3C7);
  static const danger = Color(0xFFDC2626);
  static const dangerBg = Color(0xFFFEE2E2);
  static const info = Color(0xFF7C3AED);
  static const infoBg = Color(0xFFEDE9FE);
  static const shadow = Color(0x0A000000);
}

class NexusApp extends StatefulWidget {
  const NexusApp({required this.initialLanguage, required this.initialName, required this.prefs, super.key});
  final AppLanguage initialLanguage; final String initialName; final SharedPreferences prefs;
  @override State<NexusApp> createState() => _NexusAppState();
}
class _NexusAppState extends State<NexusApp> {
  late final AppController _ctrl;
  @override void initState() { super.initState(); _ctrl = AppController(widget.initialLanguage, widget.initialName, widget.prefs); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _ctrl, builder: (context, _) {
      return MaterialApp(
        debugShowCheckedModeBanner: false, title: 'Nexus',
        scrollBehavior: const NexusDesktopScrollBehavior(),
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light, scaffoldBackgroundColor: Nx.bg, fontFamily: 'Inter',
          colorScheme: const ColorScheme.light(surface: Nx.surface, primary: Nx.primary, secondary: Nx.info, error: Nx.danger),
          splashColor: Nx.primary.withValues(alpha: 0.06), highlightColor: Nx.primary.withValues(alpha: 0.03),
        ),
        home: LiveViewScreen(controller: _ctrl),
      );
    });
  }
}

class L10n {
  static final Map<String, Map<AppLanguage, String>> _v = {
    'appSubtitle': {AppLanguage.ca: 'Control operatiu en directe', AppLanguage.es: 'Control operativo en directo', AppLanguage.en: 'Live operations control'},
    'synced': {AppLanguage.ca: 'Sincronitzat', AppLanguage.es: 'Sincronizado', AppLanguage.en: 'Synced'},
    'navLive': {AppLanguage.ca: 'Directe', AppLanguage.es: 'Directo', AppLanguage.en: 'Live'},
    'navFloor': {AppLanguage.ca: 'Sala', AppLanguage.es: 'Sala', AppLanguage.en: 'Floor'},
    'navKitchen': {AppLanguage.ca: 'Cuina', AppLanguage.es: 'Cocina', AppLanguage.en: 'Kitchen'},
    'navInsights': {AppLanguage.ca: 'Analisi', AppLanguage.es: 'Analisis', AppLanguage.en: 'Insights'},
    'navSettings': {AppLanguage.ca: 'Config.', AppLanguage.es: 'Config.', AppLanguage.en: 'Settings'},
    'kpis': {AppLanguage.ca: 'Indicadors', AppLanguage.es: 'Indicadores', AppLanguage.en: 'KPIs'},
    'floorMap': {AppLanguage.ca: 'Mapa de taules', AppLanguage.es: 'Mapa de mesas', AppLanguage.en: 'Table map'},
    'liveOrders': {AppLanguage.ca: 'Comandes en directe', AppLanguage.es: 'Pedidos en directo', AppLanguage.en: 'Live orders'},
    'revenueToday': {AppLanguage.ca: 'Ingressos avui', AppLanguage.es: 'Ingresos hoy', AppLanguage.en: 'Revenue today'},
    'averageTicket': {AppLanguage.ca: 'Tiquet mitja', AppLanguage.es: 'Ticket medio', AppLanguage.en: 'Avg. ticket'},
    'activeTables': {AppLanguage.ca: 'Taules actives', AppLanguage.es: 'Mesas activas', AppLanguage.en: 'Active tables'},
    'averageWait': {AppLanguage.ca: 'Espera mitjana', AppLanguage.es: 'Espera media', AppLanguage.en: 'Avg. wait'},
    'vsYesterday': {AppLanguage.ca: 'vs ahir', AppLanguage.es: 'vs ayer', AppLanguage.en: 'vs yesterday'},
    'lowerIsBetter': {AppLanguage.ca: 'millora operativa', AppLanguage.es: 'mejora operativa', AppLanguage.en: 'operational lift'},
    'coverage': {AppLanguage.ca: 'cobertura', AppLanguage.es: 'cobertura', AppLanguage.en: 'coverage'},
    'stageNew': {AppLanguage.ca: 'Nous', AppLanguage.es: 'Nuevos', AppLanguage.en: 'New'},
    'stageCooking': {AppLanguage.ca: 'Preparant', AppLanguage.es: 'Cocinando', AppLanguage.en: 'Cooking'},
    'stageReady': {AppLanguage.ca: 'Llestos', AppLanguage.es: 'Listos', AppLanguage.en: 'Ready'},
    'table': {AppLanguage.ca: 'Taula', AppLanguage.es: 'Mesa', AppLanguage.en: 'Table'},
    'covers': {AppLanguage.ca: 'coberts', AppLanguage.es: 'cubiertos', AppLanguage.en: 'covers'},
    'min': {AppLanguage.ca: 'min', AppLanguage.es: 'min', AppLanguage.en: 'min'},
    'guests': {AppLanguage.ca: 'comensals', AppLanguage.es: 'comensales', AppLanguage.en: 'guests'},
    'noOrders': {AppLanguage.ca: 'Sense comandes', AppLanguage.es: 'Sin pedidos', AppLanguage.en: 'No orders'},
    'statusSeated': {AppLanguage.ca: 'Nova taula', AppLanguage.es: 'Nueva mesa', AppLanguage.en: 'Just seated'},
    'statusFlowing': {AppLanguage.ca: 'En ritme', AppLanguage.es: 'En ritmo', AppLanguage.en: 'Flowing'},
    'statusWaiting': {AppLanguage.ca: 'Esperant', AppLanguage.es: 'Esperando', AppLanguage.en: 'Waiting'},
    'statusCritical': {AppLanguage.ca: 'Atencio', AppLanguage.es: 'Atencion', AppLanguage.en: 'Attention'},
    'priority': {AppLanguage.ca: 'Prioritari', AppLanguage.es: 'Prioritario', AppLanguage.en: 'Priority'},
    'moveTo': {AppLanguage.ca: 'Moure a', AppLanguage.es: 'Mover a', AppLanguage.en: 'Move to'},
    'served': {AppLanguage.ca: 'Servit', AppLanguage.es: 'Servido', AppLanguage.en: 'Served'},
    'weeklyRevenue': {AppLanguage.ca: 'Ingressos setmanals', AppLanguage.es: 'Ingresos semanales', AppLanguage.en: 'Weekly revenue'},
    'peakHours': {AppLanguage.ca: 'Hores punta', AppLanguage.es: 'Horas punta', AppLanguage.en: 'Peak hours'},
    'restaurantName': {AppLanguage.ca: 'Nom del restaurant', AppLanguage.es: 'Nombre del restaurante', AppLanguage.en: 'Restaurant name'},
    'uploadLogo': {AppLanguage.ca: 'Pujar logotip', AppLanguage.es: 'Subir logotipo', AppLanguage.en: 'Upload logo'},
    'general': {AppLanguage.ca: 'General', AppLanguage.es: 'General', AppLanguage.en: 'General'},
    'language': {AppLanguage.ca: 'Idioma', AppLanguage.es: 'Idioma', AppLanguage.en: 'Language'},
    'appearance': {AppLanguage.ca: 'Aparenca', AppLanguage.es: 'Apariencia', AppLanguage.en: 'Appearance'},
    'totalOrders': {AppLanguage.ca: 'Total comandes', AppLanguage.es: 'Total pedidos', AppLanguage.en: 'Total orders'},
    'avgTableTime': {AppLanguage.ca: 'Temps mitja taula', AppLanguage.es: 'Tiempo medio mesa', AppLanguage.en: 'Avg. table time'},
  };
  static String t(AppLanguage l, String k) => _v[k]?[l] ?? _v[k]?[AppLanguage.en] ?? k;
}

class LocalizedCopy {
  const LocalizedCopy({required this.ca, required this.es, required this.en});
  final String ca, es, en;
  String text(AppLanguage l) { switch (l) { case AppLanguage.ca: return ca; case AppLanguage.es: return es; case AppLanguage.en: return en; } }
}

enum OrderStage { fresh, cooking, ready }
enum TableShape { square, round }
enum TableMood { seated, flowing, waiting, critical }

class KpiMetric {
  const KpiMetric({required this.labelKey, required this.value, required this.delta, required this.captionKey, required this.positive, required this.icon, required this.accent, required this.accentBg});
  final String labelKey, value, delta, captionKey; final bool positive; final IconData icon; final Color accent, accentBg;
}

class FloorTable {
  const FloorTable({required this.number, required this.seats, required this.mood, required this.shape, required this.waitMinutes});
  final int number, seats, waitMinutes; final TableMood mood; final TableShape shape;
}

class OrderLine {
  const OrderLine({required this.quantity, required this.name});
  final int quantity; final LocalizedCopy name;
}

class LiveOrder {
  const LiveOrder({required this.id, required this.tableNumber, required this.guests, required this.lines, required this.total, required this.elapsedMinutes, required this.stage, this.priority = false});
  final String id; final int tableNumber, guests, elapsedMinutes; final List<OrderLine> lines; final double total; final OrderStage stage; final bool priority;
  LiveOrder copyWith({OrderStage? stage, int? elapsedMinutes}) => LiveOrder(id: id, tableNumber: tableNumber, guests: guests, lines: lines, total: total, elapsedMinutes: elapsedMinutes ?? this.elapsedMinutes, stage: stage ?? this.stage, priority: priority);
}

String formatCurrency(double v, AppLanguage l) {
  final f = v.toStringAsFixed(2).split('.'); final sep = l == AppLanguage.en ? ',' : '.'; final dec = l == AppLanguage.en ? '.' : ',';
  final c = f.first.split('').reversed.toList(); final b = StringBuffer();
  for (var i = 0; i < c.length; i++) { if (i > 0 && i % 3 == 0) b.write(sep); b.write(c[i]); }
  return '${b.toString().split('').reversed.join()}$dec${f.last} EUR';
}
String stageLabel(AppLanguage l, OrderStage s) { switch (s) { case OrderStage.fresh: return L10n.t(l, 'stageNew'); case OrderStage.cooking: return L10n.t(l, 'stageCooking'); case OrderStage.ready: return L10n.t(l, 'stageReady'); } }
Color stageColor(OrderStage s) { switch (s) { case OrderStage.fresh: return Nx.primary; case OrderStage.cooking: return Nx.warning; case OrderStage.ready: return Nx.success; } }
Color stageBg(OrderStage s) { switch (s) { case OrderStage.fresh: return Nx.primaryBg; case OrderStage.cooking: return Nx.warningBg; case OrderStage.ready: return Nx.successBg; } }
String moodLabel(AppLanguage l, TableMood m) { switch (m) { case TableMood.seated: return L10n.t(l, 'statusSeated'); case TableMood.flowing: return L10n.t(l, 'statusFlowing'); case TableMood.waiting: return L10n.t(l, 'statusWaiting'); case TableMood.critical: return L10n.t(l, 'statusCritical'); } }
Color moodColor(TableMood m) { switch (m) { case TableMood.seated: return Nx.primary; case TableMood.flowing: return Nx.success; case TableMood.waiting: return Nx.warning; case TableMood.critical: return Nx.danger; } }
Color moodBg(TableMood m) { switch (m) { case TableMood.seated: return Nx.primaryBg; case TableMood.flowing: return Nx.successBg; case TableMood.waiting: return Nx.warningBg; case TableMood.critical: return Nx.dangerBg; } }

class MockData {
  static List<KpiMetric> metrics(AppLanguage l) => [
    KpiMetric(labelKey: 'revenueToday', value: formatCurrency(1452.80, l), delta: '+12.4%', captionKey: 'vsYesterday', positive: true, icon: Icons.trending_up_rounded, accent: Nx.success, accentBg: Nx.successBg),
    KpiMetric(labelKey: 'averageTicket', value: formatCurrency(38.70, l), delta: '+3.1%', captionKey: 'vsYesterday', positive: true, icon: Icons.receipt_long_rounded, accent: Nx.info, accentBg: Nx.infoBg),
    const KpiMetric(labelKey: 'activeTables', value: '18 / 24', delta: '+4', captionKey: 'coverage', positive: true, icon: Icons.table_restaurant_rounded, accent: Nx.primary, accentBg: Nx.primaryBg),
    const KpiMetric(labelKey: 'averageWait', value: '11 min', delta: '-2 min', captionKey: 'lowerIsBetter', positive: true, icon: Icons.timer_outlined, accent: Nx.warning, accentBg: Nx.warningBg),
  ];

  static List<FloorTable> tables() => const [
    FloorTable(number: 1, seats: 2, mood: TableMood.flowing, shape: TableShape.round, waitMinutes: 8),
    FloorTable(number: 2, seats: 4, mood: TableMood.seated, shape: TableShape.square, waitMinutes: 3),
    FloorTable(number: 3, seats: 4, mood: TableMood.flowing, shape: TableShape.square, waitMinutes: 10),
    FloorTable(number: 4, seats: 2, mood: TableMood.waiting, shape: TableShape.round, waitMinutes: 18),
    FloorTable(number: 5, seats: 6, mood: TableMood.critical, shape: TableShape.square, waitMinutes: 24),
    FloorTable(number: 6, seats: 2, mood: TableMood.flowing, shape: TableShape.round, waitMinutes: 7),
    FloorTable(number: 7, seats: 4, mood: TableMood.seated, shape: TableShape.square, waitMinutes: 4),
    FloorTable(number: 8, seats: 8, mood: TableMood.flowing, shape: TableShape.square, waitMinutes: 13),
    FloorTable(number: 9, seats: 4, mood: TableMood.waiting, shape: TableShape.round, waitMinutes: 21),
    FloorTable(number: 10, seats: 2, mood: TableMood.flowing, shape: TableShape.round, waitMinutes: 9),
    FloorTable(number: 11, seats: 6, mood: TableMood.critical, shape: TableShape.square, waitMinutes: 27),
    FloorTable(number: 12, seats: 4, mood: TableMood.flowing, shape: TableShape.square, waitMinutes: 12),
    FloorTable(number: 13, seats: 2, mood: TableMood.seated, shape: TableShape.round, waitMinutes: 2),
    FloorTable(number: 14, seats: 4, mood: TableMood.flowing, shape: TableShape.square, waitMinutes: 14),
    FloorTable(number: 15, seats: 4, mood: TableMood.waiting, shape: TableShape.square, waitMinutes: 19),
    FloorTable(number: 16, seats: 6, mood: TableMood.flowing, shape: TableShape.round, waitMinutes: 11),
    FloorTable(number: 17, seats: 2, mood: TableMood.seated, shape: TableShape.round, waitMinutes: 5),
    FloorTable(number: 18, seats: 4, mood: TableMood.critical, shape: TableShape.square, waitMinutes: 31),
    FloorTable(number: 19, seats: 8, mood: TableMood.flowing, shape: TableShape.square, waitMinutes: 15),
    FloorTable(number: 20, seats: 2, mood: TableMood.flowing, shape: TableShape.round, waitMinutes: 6),
    FloorTable(number: 21, seats: 4, mood: TableMood.waiting, shape: TableShape.square, waitMinutes: 22),
    FloorTable(number: 22, seats: 6, mood: TableMood.flowing, shape: TableShape.round, waitMinutes: 12),
    FloorTable(number: 23, seats: 4, mood: TableMood.seated, shape: TableShape.square, waitMinutes: 1),
    FloorTable(number: 24, seats: 2, mood: TableMood.flowing, shape: TableShape.round, waitMinutes: 9),
  ];

  static List<LiveOrder> orders() => const [
    LiveOrder(id: 'N-1048', tableNumber: 4, guests: 2, elapsedMinutes: 4, total: 42.50, stage: OrderStage.fresh, priority: true, lines: [
      OrderLine(quantity: 2, name: LocalizedCopy(ca: 'Burger trufada', es: 'Burger trufada', en: 'Truffled burger')),
      OrderLine(quantity: 1, name: LocalizedCopy(ca: 'Patates braves', es: 'Patatas bravas', en: 'Patatas bravas')),
      OrderLine(quantity: 2, name: LocalizedCopy(ca: 'IPA artesanal', es: 'IPA artesanal', en: 'Craft IPA')),
    ]),
    LiveOrder(id: 'N-1049', tableNumber: 11, guests: 6, elapsedMinutes: 9, total: 96.40, stage: OrderStage.fresh, lines: [
      OrderLine(quantity: 3, name: LocalizedCopy(ca: 'Tacos de cochinita', es: 'Tacos de cochinita', en: 'Cochinita tacos')),
      OrderLine(quantity: 2, name: LocalizedCopy(ca: 'Amanida de burrata', es: 'Ensalada de burrata', en: 'Burrata salad')),
      OrderLine(quantity: 1, name: LocalizedCopy(ca: 'Ribeye 400g', es: 'Ribeye 400g', en: 'Ribeye 400g')),
    ]),
    LiveOrder(id: 'N-1050', tableNumber: 2, guests: 4, elapsedMinutes: 12, total: 68.20, stage: OrderStage.cooking, lines: [
      OrderLine(quantity: 2, name: LocalizedCopy(ca: 'Risotto de ceps', es: 'Risotto de setas', en: 'Mushroom risotto')),
      OrderLine(quantity: 1, name: LocalizedCopy(ca: 'Pop a la brasa', es: 'Pulpo a la brasa', en: 'Charred octopus')),
      OrderLine(quantity: 2, name: LocalizedCopy(ca: 'Llimonada de romani', es: 'Limonada de romero', en: 'Rosemary lemonade')),
    ]),
    LiveOrder(id: 'N-1051', tableNumber: 9, guests: 4, elapsedMinutes: 18, total: 74.90, stage: OrderStage.cooking, priority: true, lines: [
      OrderLine(quantity: 1, name: LocalizedCopy(ca: 'Arros melos de gamba', es: 'Arroz meloso de gamba', en: 'Prawn creamy rice')),
      OrderLine(quantity: 2, name: LocalizedCopy(ca: 'Croquetes de pernil', es: 'Croquetas de jamon', en: 'Ham croquettes')),
      OrderLine(quantity: 1, name: LocalizedCopy(ca: 'Tarta fina de poma', es: 'Tarta fina de manzana', en: 'Apple tart')),
    ]),
    LiveOrder(id: 'N-1052', tableNumber: 16, guests: 6, elapsedMinutes: 15, total: 121.10, stage: OrderStage.cooking, lines: [
      OrderLine(quantity: 2, name: LocalizedCopy(ca: 'Peix del dia', es: 'Pescado del dia', en: 'Catch of the day')),
      OrderLine(quantity: 2, name: LocalizedCopy(ca: 'Steak tartar', es: 'Steak tartar', en: 'Steak tartare')),
      OrderLine(quantity: 1, name: LocalizedCopy(ca: 'Verdures escalivades', es: 'Verduras asadas', en: 'Roasted vegetables')),
    ]),
    LiveOrder(id: 'N-1053', tableNumber: 7, guests: 4, elapsedMinutes: 21, total: 55.30, stage: OrderStage.ready, lines: [
      OrderLine(quantity: 2, name: LocalizedCopy(ca: 'Canelons de rostit', es: 'Canelones de rustido', en: 'Roast cannelloni')),
      OrderLine(quantity: 1, name: LocalizedCopy(ca: 'Brioix de costella', es: 'Brioche de costilla', en: 'Short rib brioche')),
      OrderLine(quantity: 2, name: LocalizedCopy(ca: 'Cafe fred', es: 'Cafe frio', en: 'Cold brew')),
    ]),
    LiveOrder(id: 'N-1054', tableNumber: 18, guests: 4, elapsedMinutes: 24, total: 88.60, stage: OrderStage.ready, priority: true, lines: [
      OrderLine(quantity: 1, name: LocalizedCopy(ca: 'Llobarro a la sal', es: 'Lubina a la sal', en: 'Salt baked sea bass')),
      OrderLine(quantity: 2, name: LocalizedCopy(ca: 'Carxofes confitades', es: 'Alcachofas confitadas', en: 'Confit artichokes')),
      OrderLine(quantity: 2, name: LocalizedCopy(ca: 'Copa de cava brut', es: 'Copa de cava brut', en: 'Brut cava glass')),
    ]),
  ];
}


// === SCREENS ===
class LiveViewScreen extends StatefulWidget {
  const LiveViewScreen({required this.controller, super.key});
  final AppController controller;
  @override State<LiveViewScreen> createState() => _LiveViewScreenState();
}
class _LiveViewScreenState extends State<LiveViewScreen> {
  late List<LiveOrder> _orders;
  int _navIndex = 0;
  @override void initState() { super.initState(); _orders = MockData.orders(); }
  void _moveOrder(LiveOrder order, OrderStage stage) {
    setState(() { final i = _orders.indexWhere((o) => o.id == order.id); if (i == -1) return; _orders[i] = _orders[i].copyWith(stage: stage); });
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: widget.controller, builder: (context, _) {
      final lang = widget.controller.language;
      return LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 780;
        return Scaffold(backgroundColor: Nx.bg,
          bottomNavigationBar: compact ? NxBottomNav(index: _navIndex, lang: lang, onTap: (v) => setState(() => _navIndex = v)) : null,
          body: Column(children: [
            const _TitleBar(),
            Expanded(child: SafeArea(bottom: !compact, child: Row(children: [
              if (!compact) NxRail(index: _navIndex, lang: lang, onTap: (v) => setState(() => _navIndex = v)),
              Expanded(child: Column(children: [
                NxTopBar(controller: widget.controller),
                Expanded(child: IndexedStack(index: _navIndex, children: [
                  _LiveScreen(lang: lang, orders: _orders, onMove: _moveOrder),
                  _FloorScreen(lang: lang),
                  _KitchenScreen(lang: lang, orders: _orders, onMove: _moveOrder),
                  _InsightsScreen(lang: lang),
                  _SettingsScreen(controller: widget.controller),
                ])),
              ])),
            ]))),
          ]),
        );
      });
    });
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar();
  @override Widget build(BuildContext context) {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return const SizedBox.shrink();
    return const SizedBox(height: 32, child: WindowCaption(brightness: Brightness.light, backgroundColor: Colors.transparent));
  }
}

class NxTopBar extends StatelessWidget {
  const NxTopBar({required this.controller, super.key});
  final AppController controller;
  @override Widget build(BuildContext context) {
    final lang = controller.language;
    return Container(height: 64, padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(color: Nx.surface, border: Border(bottom: BorderSide(color: Nx.border))),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: Nx.primary, borderRadius: BorderRadius.circular(8)),
          child: const Center(child: Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)))),
        const SizedBox(width: 10),
        Text(controller.restaurantName, style: const TextStyle(color: Nx.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(width: 12),
        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Nx.success, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(L10n.t(lang, 'synced'), style: const TextStyle(color: Nx.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
        const Spacer(),
        _LangSwitch(lang: lang, onChanged: controller.setLanguage),
      ]),
    );
  }
}

class _LangSwitch extends StatelessWidget {
  const _LangSwitch({required this.lang, required this.onChanged});
  final AppLanguage lang; final ValueChanged<AppLanguage> onChanged;
  @override Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: Nx.surfaceAlt, borderRadius: BorderRadius.circular(8), border: Border.all(color: Nx.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: AppLanguage.values.map((item) {
        final sel = item == lang;
        return InkWell(borderRadius: BorderRadius.circular(6), onTap: () => onChanged(item),
          child: Container(width: 38, height: 28, alignment: Alignment.center,
            decoration: BoxDecoration(color: sel ? Nx.surface : Colors.transparent, borderRadius: BorderRadius.circular(6),
              border: Border.all(color: sel ? Nx.border : Colors.transparent),
              boxShadow: sel ? [const BoxShadow(color: Nx.shadow, blurRadius: 2, offset: Offset(0, 1))] : null),
            child: Text(item.code, style: TextStyle(color: sel ? Nx.textPrimary : Nx.textMuted, fontWeight: FontWeight.w700, fontSize: 11))));
      }).toList()));
  }
}

class NxRail extends StatelessWidget {
  const NxRail({required this.index, required this.lang, required this.onTap, super.key});
  final int index; final AppLanguage lang; final ValueChanged<int> onTap;
  @override Widget build(BuildContext context) {
    final items = [
      (Icons.space_dashboard_outlined, 'navLive'),
      (Icons.grid_view_rounded, 'navFloor'),
      (Icons.restaurant_outlined, 'navKitchen'),
      (Icons.insights_outlined, 'navInsights'),
      (Icons.settings_outlined, 'navSettings'),
    ];
    return Container(width: 80, padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(color: Nx.surface, border: Border(right: BorderSide(color: Nx.border))),
      child: Column(children: [
        for (var i = 0; i < items.length; i++) ...[
          _RailBtn(icon: items[i].$1, label: L10n.t(lang, items[i].$2), sel: index == i, onTap: () => onTap(i)),
          if (i < items.length - 1) const SizedBox(height: 4),
          if (i == 3) const Spacer(),
        ],
      ]));
  }
}

class _RailBtn extends StatelessWidget {
  const _RailBtn({required this.icon, required this.label, required this.sel, required this.onTap});
  final IconData icon; final String label; final bool sel; final VoidCallback onTap;
  @override Widget build(BuildContext context) {
    return InkWell(borderRadius: BorderRadius.circular(10), onTap: onTap,
      child: Container(width: 64, padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: sel ? Nx.primaryBg : Colors.transparent, borderRadius: BorderRadius.circular(10)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20, color: sel ? Nx.primary : Nx.textMuted),
          const SizedBox(height: 4),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: sel ? Nx.primary : Nx.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
        ])));
  }
}

class NxBottomNav extends StatelessWidget {
  const NxBottomNav({required this.index, required this.lang, required this.onTap, super.key});
  final int index; final AppLanguage lang; final ValueChanged<int> onTap;
  @override Widget build(BuildContext context) {
    final items = [(Icons.space_dashboard_outlined, 'navLive'), (Icons.grid_view_rounded, 'navFloor'),
      (Icons.restaurant_outlined, 'navKitchen'), (Icons.insights_outlined, 'navInsights'), (Icons.settings_outlined, 'navSettings')];
    return SafeArea(top: false, child: Container(height: 64,
      decoration: const BoxDecoration(color: Nx.surface, border: Border(top: BorderSide(color: Nx.border))),
      child: Row(children: [for (var i = 0; i < items.length; i++)
        Expanded(child: InkWell(onTap: () => onTap(i), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(items[i].$1, size: 20, color: index == i ? Nx.primary : Nx.textMuted),
          const SizedBox(height: 3),
          Text(L10n.t(lang, items[i].$2), style: TextStyle(color: index == i ? Nx.primary : Nx.textMuted, fontSize: 9, fontWeight: FontWeight.w600)),
        ])))])));
  }
}


// === SCREEN IMPLEMENTATIONS ===
class _LiveScreen extends StatelessWidget {
  const _LiveScreen({required this.lang, required this.orders, required this.onMove});
  final AppLanguage lang; final List<LiveOrder> orders; final void Function(LiveOrder, OrderStage) onMove;
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      KpiStrip(lang: lang), const SizedBox(height: 16),
      Expanded(child: _Kanban(lang: lang, orders: orders, onMove: onMove)),
    ]));
  }
}

class _FloorScreen extends StatelessWidget {
  const _FloorScreen({required this.lang});
  final AppLanguage lang;
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(20), child: _TableMap(lang: lang, fill: true));
  }
}

class _KitchenScreen extends StatelessWidget {
  const _KitchenScreen({required this.lang, required this.orders, required this.onMove});
  final AppLanguage lang; final List<LiveOrder> orders; final void Function(LiveOrder, OrderStage) onMove;
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(20), child: _Kanban(lang: lang, orders: orders, onMove: onMove));
  }
}

// === KPI STRIP ===
class KpiStrip extends StatelessWidget {
  const KpiStrip({required this.lang, super.key});
  final AppLanguage lang;
  @override Widget build(BuildContext context) {
    final m = MockData.metrics(lang);
    return Row(children: [for (var i = 0; i < m.length; i++) ...[
      Expanded(child: _KpiCard(m: m[i], lang: lang)), if (i < m.length - 1) const SizedBox(width: 12)]]);
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.m, required this.lang});
  final KpiMetric m; final AppLanguage lang;
  @override Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Nx.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Nx.border),
        boxShadow: const [BoxShadow(color: Nx.shadow, blurRadius: 4, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: m.accentBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(m.icon, size: 18, color: m.accent)),
          const SizedBox(width: 10),
          Expanded(child: Text(L10n.t(lang, m.labelKey), maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Nx.textSecondary, fontSize: 12, fontWeight: FontWeight.w500))),
        ]),
        const SizedBox(height: 12),
        Text(m.value, style: const TextStyle(color: Nx.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: m.positive ? Nx.successBg : Nx.dangerBg, borderRadius: BorderRadius.circular(99)),
            child: Text(m.delta, style: TextStyle(color: m.positive ? Nx.success : Nx.danger, fontSize: 11, fontWeight: FontWeight.w700))),
          const SizedBox(width: 6),
          Expanded(child: Text(L10n.t(lang, m.captionKey), maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Nx.textMuted, fontSize: 11, fontWeight: FontWeight.w500))),
        ]),
      ]));
  }
}

// === TABLE MAP ===
class _TableMap extends StatelessWidget {
  const _TableMap({required this.lang, this.fill = false});
  final AppLanguage lang; final bool fill;
  @override Widget build(BuildContext context) {
    final tables = MockData.tables();
    return _Panel(title: L10n.t(lang, 'floorMap'), icon: Icons.grid_view_rounded, expand: fill,
      child: LayoutBuilder(builder: (context, c) {
        final cols = c.maxWidth >= 900 ? 8 : c.maxWidth >= 600 ? 6 : 4;
        return GridView.builder(
          physics: fill ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
          shrinkWrap: !fill, itemCount: tables.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.0),
          itemBuilder: (_, i) => _TableTile(t: tables[i], lang: lang));
      }));
  }
}

class _TableTile extends StatelessWidget {
  const _TableTile({required this.t, required this.lang});
  final FloorTable t; final AppLanguage lang;
  @override Widget build(BuildContext context) {
    final c = moodColor(t.mood); final bg = moodBg(t.mood);
    final round = t.shape == TableShape.round;
    return Container(padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bg, shape: round ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: round ? null : BorderRadius.circular(10), border: Border.all(color: c.withValues(alpha: 0.3))),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
        Text('${t.number}', style: TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text('${t.seats} ${L10n.t(lang, 'covers')}', maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Nx.textSecondary, fontSize: 9, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(99)),
          child: Text('${t.waitMinutes} min', style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w700))),
      ]));
  }
}

// === KANBAN ===
class _Kanban extends StatelessWidget {
  const _Kanban({required this.lang, required this.orders, required this.onMove});
  final AppLanguage lang; final List<LiveOrder> orders; final void Function(LiveOrder, OrderStage) onMove;
  @override Widget build(BuildContext context) {
    return _Panel(title: L10n.t(lang, 'liveOrders'), icon: Icons.receipt_long_rounded, expand: true,
      child: LayoutBuilder(builder: (context, c) {
        if (c.maxWidth >= 600) {
          return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final s in OrderStage.values) ...[
              Expanded(child: _OrderCol(stage: s, lang: lang, orders: orders.where((o) => o.stage == s).toList(), onMove: onMove)),
              if (s != OrderStage.values.last) const SizedBox(width: 10),
            ]]);
        }
        return SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (final s in OrderStage.values) ...[
            SizedBox(width: 280, child: _OrderCol(stage: s, lang: lang, orders: orders.where((o) => o.stage == s).toList(), onMove: onMove)),
            if (s != OrderStage.values.last) const SizedBox(width: 10),
          ]]));
      }));
  }
}

class _OrderCol extends StatelessWidget {
  const _OrderCol({required this.stage, required this.lang, required this.orders, required this.onMove});
  final OrderStage stage; final AppLanguage lang; final List<LiveOrder> orders; final void Function(LiveOrder, OrderStage) onMove;
  @override Widget build(BuildContext context) {
    final c = stageColor(stage); final bg = stageBg(stage);
    return Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Nx.surfaceAlt, borderRadius: BorderRadius.circular(10), border: Border.all(color: Nx.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(stageLabel(lang, stage), style: const TextStyle(color: Nx.textPrimary, fontSize: 14, fontWeight: FontWeight.w700))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
            child: Text('${orders.length}', style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w800))),
        ]),
        const SizedBox(height: 10),
        Expanded(child: orders.isEmpty
          ? Center(child: Text(L10n.t(lang, 'noOrders'), style: const TextStyle(color: Nx.textMuted, fontSize: 12)))
          : ListView.separated(itemCount: orders.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _OrderCard(order: orders[i], lang: lang, onMove: onMove))),
      ]));
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.lang, required this.onMove});
  final LiveOrder order; final AppLanguage lang; final void Function(LiveOrder, OrderStage) onMove;
  OrderStage? get _prev => order.stage == OrderStage.fresh ? null : order.stage == OrderStage.cooking ? OrderStage.fresh : OrderStage.cooking;
  OrderStage? get _next => order.stage == OrderStage.fresh ? OrderStage.cooking : order.stage == OrderStage.cooking ? OrderStage.ready : null;
  @override Widget build(BuildContext context) {
    final c = stageColor(order.stage);
    return Container(padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Nx.surface, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: order.priority ? Nx.danger.withValues(alpha: 0.4) : Nx.border),
        boxShadow: const [BoxShadow(color: Nx.shadow, blurRadius: 3, offset: Offset(0, 1))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('${L10n.t(lang, 'table')} ${order.tableNumber}', style: const TextStyle(color: Nx.textPrimary, fontSize: 14, fontWeight: FontWeight.w700))),
          Text(order.id, style: const TextStyle(color: Nx.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 4),
        Text('${order.guests} ${L10n.t(lang, 'guests')}', style: const TextStyle(color: Nx.textSecondary, fontSize: 11)),
        const SizedBox(height: 8),
        for (final line in order.lines) Padding(padding: const EdgeInsets.only(bottom: 3),
          child: Text('${line.quantity}x ${line.name.text(lang)}', style: const TextStyle(color: Nx.textSecondary, fontSize: 12, fontWeight: FontWeight.w500))),
        const SizedBox(height: 8),
        Row(children: [
          Text(formatCurrency(order.total, lang), style: const TextStyle(color: Nx.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (order.priority) ...[
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Nx.dangerBg, borderRadius: BorderRadius.circular(99)),
              child: Text(L10n.t(lang, 'priority'), style: const TextStyle(color: Nx.danger, fontSize: 9, fontWeight: FontWeight.w700))),
            const SizedBox(width: 4)],
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: stageBg(order.stage), borderRadius: BorderRadius.circular(99)),
            child: Text('${order.elapsedMinutes} min', style: TextStyle(color: c, fontSize: 9, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          if (_prev != null) ...[
            Expanded(child: _ActionBtn(label: 'â† ${stageLabel(lang, _prev!)}', color: Nx.textSecondary, bg: Nx.surfaceAlt, onTap: () => onMove(order, _prev!))),
            const SizedBox(width: 6)],
          if (_next != null)
            Expanded(child: _ActionBtn(label: '${stageLabel(lang, _next!)} â†’', color: c, bg: stageBg(_next!), onTap: () => onMove(order, _next!)))
          else
            Expanded(child: _ActionBtn(label: 'âœ“ ${L10n.t(lang, 'served')}', color: Nx.success, bg: Nx.successBg, onTap: () {})),
        ]),
      ]));
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.label, required this.color, required this.bg, required this.onTap});
  final String label; final Color color, bg; final VoidCallback onTap;
  @override Widget build(BuildContext context) {
    return InkWell(borderRadius: BorderRadius.circular(6), onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 6), alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))));
  }
}

// === PANEL ===
class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.icon, required this.child, this.expand = false});
  final String title; final IconData icon; final Widget child; final bool expand;
  @override Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Nx.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Nx.border),
        boxShadow: const [BoxShadow(color: Nx.shadow, blurRadius: 4, offset: Offset(0, 2))]),
      child: Column(mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: Nx.textSecondary), const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Nx.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        if (expand) Expanded(child: child) else child,
      ]));
  }
}


// === INSIGHTS SCREEN ===
class _InsightsScreen extends StatelessWidget {
  const _InsightsScreen({required this.lang});
  final AppLanguage lang;
  @override Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      Row(children: [
        Expanded(child: _SummaryCard(label: L10n.t(lang, 'revenueToday'), value: formatCurrency(1452.80, lang), icon: Icons.trending_up, color: Nx.success)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(label: L10n.t(lang, 'totalOrders'), value: '47', icon: Icons.receipt_long, color: Nx.primary)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(label: L10n.t(lang, 'avgTableTime'), value: '48 min', icon: Icons.timer_outlined, color: Nx.warning)),
      ]),
      const SizedBox(height: 16),
      Expanded(child: Row(children: [
        Expanded(child: _ChartPanel(title: L10n.t(lang, 'weeklyRevenue'), child: _WeeklyChart(lang: lang))),
        const SizedBox(width: 16),
        Expanded(child: _ChartPanel(title: L10n.t(lang, 'peakHours'), child: const _PeakChart())),
      ])),
    ]));
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});
  final String label, value; final IconData icon; final Color color;
  @override Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Nx.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Nx.border),
        boxShadow: const [BoxShadow(color: Nx.shadow, blurRadius: 4, offset: Offset(0, 2))]),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Nx.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Nx.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
        ])),
      ]));
  }
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({required this.title, required this.child});
  final String title; final Widget child;
  @override Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Nx.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Nx.border),
        boxShadow: const [BoxShadow(color: Nx.shadow, blurRadius: 4, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Nx.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20), Expanded(child: child),
      ]));
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.lang});
  final AppLanguage lang;
  @override Widget build(BuildContext context) {
    final data = [1240.0, 980, 1350, 1100, 1580, 1820, 1650];
    final labels = lang == AppLanguage.en ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
      : lang == AppLanguage.es ? ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom']
      : ['Dl', 'Dt', 'Dc', 'Dj', 'Dv', 'Ds', 'Dg'];
    final mx = data.reduce(math.max);
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      for (var i = 0; i < data.length; i++) ...[
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text(formatCurrency(data[i].toDouble(), lang).split(' ').first, style: const TextStyle(color: Nx.textMuted, fontSize: 9, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          FractionallySizedBox(widthFactor: 0.7,
            child: Container(height: (data[i] / mx) * 180, decoration: BoxDecoration(
              color: i == 5 ? Nx.primary : Nx.primaryBg, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 8),
          Text(labels[i], style: const TextStyle(color: Nx.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
        ])),
        if (i < data.length - 1) const SizedBox(width: 4),
      ]]);
  }
}

class _PeakChart extends StatelessWidget {
  const _PeakChart();
  @override Widget build(BuildContext context) {
    final data = [2, 5, 12, 18, 22, 15, 20, 24, 18, 8, 3, 1];
    final hours = List.generate(12, (i) => '${i + 11}h');
    final mx = data.reduce(math.max);
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      for (var i = 0; i < data.length; i++) ...[
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('${data[i]}', style: const TextStyle(color: Nx.textMuted, fontSize: 9, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          FractionallySizedBox(widthFactor: 0.65,
            child: Container(height: (data[i] / mx) * 180, decoration: BoxDecoration(
              color: data[i] == mx ? Nx.warning : Nx.warningBg, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 8),
          Text(hours[i], style: const TextStyle(color: Nx.textSecondary, fontSize: 8, fontWeight: FontWeight.w600)),
        ])),
        if (i < data.length - 1) const SizedBox(width: 2),
      ]]);
  }
}

// === SETTINGS SCREEN ===
class _SettingsScreen extends StatefulWidget {
  const _SettingsScreen({required this.controller});
  final AppController controller;
  @override State<_SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<_SettingsScreen> {
  late final TextEditingController _nameCtrl;
  @override void initState() { super.initState(); _nameCtrl = TextEditingController(text: widget.controller.restaurantName); }
  @override void dispose() { _nameCtrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final lang = widget.controller.language;
    return Padding(padding: const EdgeInsets.all(20), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(L10n.t(lang, 'navSettings'), style: const TextStyle(color: Nx.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 24),
      // General section
      Container(padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Nx.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Nx.border),
          boxShadow: const [BoxShadow(color: Nx.shadow, blurRadius: 4, offset: Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(L10n.t(lang, 'general'), style: const TextStyle(color: Nx.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Text(L10n.t(lang, 'restaurantName'), style: const TextStyle(color: Nx.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SizedBox(width: 400, child: TextField(controller: _nameCtrl,
            onChanged: (v) => widget.controller.setRestaurantName(v),
            style: const TextStyle(color: Nx.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            decoration: InputDecoration(hintText: 'Restaurant name', hintStyle: const TextStyle(color: Nx.textMuted),
              filled: true, fillColor: Nx.surfaceAlt, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Nx.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Nx.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Nx.primary, width: 1.5))))),
          const SizedBox(height: 24),
          Text(L10n.t(lang, 'uploadLogo'), style: const TextStyle(color: Nx.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          InkWell(onTap: () {}, borderRadius: BorderRadius.circular(8),
            child: Container(width: 400, height: 120,
              decoration: BoxDecoration(color: Nx.surfaceAlt, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Nx.border, style: BorderStyle.solid)),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.cloud_upload_outlined, size: 32, color: Nx.textMuted),
                SizedBox(height: 8),
                Text('Click to upload', style: TextStyle(color: Nx.textMuted, fontSize: 12, fontWeight: FontWeight.w500)),
              ]))),
        ])),
      const SizedBox(height: 20),
      // Language section
      Container(padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Nx.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: Nx.border),
          boxShadow: const [BoxShadow(color: Nx.shadow, blurRadius: 4, offset: Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(L10n.t(lang, 'language'), style: const TextStyle(color: Nx.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          for (final item in AppLanguage.values)
            Padding(padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(borderRadius: BorderRadius.circular(8), onTap: () => widget.controller.setLanguage(item),
                child: Container(width: 400, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(color: item == lang ? Nx.primaryBg : Nx.surfaceAlt, borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: item == lang ? Nx.primary.withValues(alpha: 0.3) : Nx.border)),
                  child: Row(children: [
                    Icon(item == lang ? Icons.radio_button_checked : Icons.radio_button_off, size: 18, color: item == lang ? Nx.primary : Nx.textMuted),
                    const SizedBox(width: 10),
                    Text(item.label, style: TextStyle(color: item == lang ? Nx.primary : Nx.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ])))),
        ])),
    ])));
  }
}

