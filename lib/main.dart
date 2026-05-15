// VERSION DEFINITIVA - CORREGIDA Y LIMPIA
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
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(1280, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'Nexus',
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('language') ?? 'ES';
  final initialLanguage = AppLanguage.values.firstWhere(
    (e) => e.code == langCode,
    orElse: () => AppLanguage.es,
  );

  runApp(NexusApp(initialLanguage: initialLanguage, prefs: prefs));
}

enum AppLanguage { ca, es, en }

extension AppLanguageMeta on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.ca:
        return 'CA';
      case AppLanguage.es:
        return 'ES';
      case AppLanguage.en:
        return 'EN';
    }
  }

  String get semanticName {
    switch (this) {
      case AppLanguage.ca:
        return 'Catala';
      case AppLanguage.es:
        return 'Espanol';
      case AppLanguage.en:
        return 'English';
    }
  }
}

class LocaleController extends ChangeNotifier {
  LocaleController(this._language, this._prefs);

  AppLanguage _language;
  final SharedPreferences _prefs;

  AppLanguage get language => _language;

  void setLanguage(AppLanguage value) {
    if (_language == value) return;
    _language = value;
    _prefs.setString('language', value.code);
    notifyListeners();
  }
}

class NexusDesktopScrollBehavior extends MaterialScrollBehavior {
  const NexusDesktopScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}


class NexusApp extends StatefulWidget {
  const NexusApp({required this.initialLanguage, required this.prefs, super.key});
  
  final AppLanguage initialLanguage;
  final SharedPreferences prefs;

  @override
  State<NexusApp> createState() => _NexusAppState();
}

class _NexusAppState extends State<NexusApp> {
  late final LocaleController _localeController;

  @override
  void initState() {
    super.initState();
    _localeController = LocaleController(widget.initialLanguage, widget.prefs);
  }

  @override
  void dispose() {
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _localeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nexus',
          scrollBehavior: const NexusDesktopScrollBehavior(),
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: NexusColors.background,
            fontFamily: 'Inter',
            colorScheme: const ColorScheme.dark(
              surface: NexusColors.panel,
              primary: NexusColors.accentGreen,
              secondary: NexusColors.accentBlue,
              error: NexusColors.accentRed,
            ),
            splashColor: NexusColors.accentGreen.withValues(alpha: 0.08),
            highlightColor: NexusColors.accentGreen.withValues(alpha: 0.04),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: NexusColors.accentGreen,
              selectionColor: Color(0x3347F3A3),
            ),
          ),
          home: LiveViewScreen(controller: _localeController),
        );
      },
    );
  }
}

class NexusColors {
  static const Color background = Color(0xFF111111);
  static const Color backgroundElevated = Color(0xFF151515);
  static const Color panel = Color(0xFF1A1A1A);
  static const Color panelHigh = Color(0xFF202020);
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderBright = Color(0xFF383838);
  static const Color textPrimary = Color(0xFFF2F2F2);
  static const Color textSecondary = Color(0xFFA6A6A6);
  static const Color textMuted = Color(0xFF6E6E6E);
  static const Color accentGreen = Color(0xFF47F3A3);
  static const Color accentAmber = Color(0xFFFFB84D);
  static const Color accentRed = Color(0xFFFF6B6B);
  static const Color accentBlue = Color(0xFF6EA8FF);
  static const Color accentViolet = Color(0xFFB18CFF);
}

class L10n {
  static final Map<String, Map<AppLanguage, String>> _values = {
    'appSubtitle': {
      AppLanguage.ca: 'Control operatiu en directe',
      AppLanguage.es: 'Control operativo en directo',
      AppLanguage.en: 'Live operations control',
    },
    'synced': {
      AppLanguage.ca: 'Sincronitzat',
      AppLanguage.es: 'Sincronizado',
      AppLanguage.en: 'Synced',
    },
    'language': {
      AppLanguage.ca: 'Idioma',
      AppLanguage.es: 'Idioma',
      AppLanguage.en: 'Language',
    },
    'navLive': {
      AppLanguage.ca: 'Directe',
      AppLanguage.es: 'Directo',
      AppLanguage.en: 'Live',
    },
    'navFloor': {
      AppLanguage.ca: 'Sala',
      AppLanguage.es: 'Sala',
      AppLanguage.en: 'Floor',
    },
    'navKitchen': {
      AppLanguage.ca: 'Cuina',
      AppLanguage.es: 'Cocina',
      AppLanguage.en: 'Kitchen',
    },
    'navInsights': {
      AppLanguage.ca: 'Analisi',
      AppLanguage.es: 'Analisis',
      AppLanguage.en: 'Insights',
    },
    'kpis': {
      AppLanguage.ca: 'Indicadors',
      AppLanguage.es: 'Indicadores',
      AppLanguage.en: 'KPIs',
    },
    'floorMap': {
      AppLanguage.ca: 'Mapa termic de taules',
      AppLanguage.es: 'Mapa termico de mesas',
      AppLanguage.en: 'Thermal table map',
    },
    'liveOrders': {
      AppLanguage.ca: 'Comandes en directe',
      AppLanguage.es: 'Pedidos en directo',
      AppLanguage.en: 'Live orders',
    },
    'revenueToday': {
      AppLanguage.ca: 'Ingressos avui',
      AppLanguage.es: 'Ingresos hoy',
      AppLanguage.en: 'Revenue today',
    },
    'averageTicket': {
      AppLanguage.ca: 'Tiquet mitja',
      AppLanguage.es: 'Ticket medio',
      AppLanguage.en: 'Average ticket',
    },
    'activeTables': {
      AppLanguage.ca: 'Taules actives',
      AppLanguage.es: 'Mesas activas',
      AppLanguage.en: 'Active tables',
    },
    'averageWait': {
      AppLanguage.ca: 'Espera mitjana',
      AppLanguage.es: 'Espera media',
      AppLanguage.en: 'Average wait',
    },
    'vsYesterday': {
      AppLanguage.ca: 'vs ahir',
      AppLanguage.es: 'vs ayer',
      AppLanguage.en: 'vs yesterday',
    },
    'lowerIsBetter': {
      AppLanguage.ca: 'millora operativa',
      AppLanguage.es: 'mejora operativa',
      AppLanguage.en: 'operational lift',
    },
    'coverage': {
      AppLanguage.ca: 'cobertura',
      AppLanguage.es: 'cobertura',
      AppLanguage.en: 'coverage',
    },
    'stageNew': {
      AppLanguage.ca: 'Nous',
      AppLanguage.es: 'Nuevos',
      AppLanguage.en: 'New',
    },
    'stageCooking': {
      AppLanguage.ca: 'Preparant',
      AppLanguage.es: 'Cocinando',
      AppLanguage.en: 'Cooking',
    },
    'stageReady': {
      AppLanguage.ca: 'Llestos',
      AppLanguage.es: 'Listos',
      AppLanguage.en: 'Ready',
    },
    'table': {
      AppLanguage.ca: 'Taula',
      AppLanguage.es: 'Mesa',
      AppLanguage.en: 'Table',
    },
    'covers': {
      AppLanguage.ca: 'coberts',
      AppLanguage.es: 'cubiertos',
      AppLanguage.en: 'covers',
    },
    'min': {
      AppLanguage.ca: 'min',
      AppLanguage.es: 'min',
      AppLanguage.en: 'min',
    },
    'guests': {
      AppLanguage.ca: 'comensals',
      AppLanguage.es: 'comensales',
      AppLanguage.en: 'guests',
    },
    'noOrders': {
      AppLanguage.ca: 'Sense comandes',
      AppLanguage.es: 'Sin pedidos',
      AppLanguage.en: 'No orders',
    },
    'statusSeated': {
      AppLanguage.ca: 'Nova taula',
      AppLanguage.es: 'Nueva mesa',
      AppLanguage.en: 'Recently seated',
    },
    'statusFlowing': {
      AppLanguage.ca: 'En ritme',
      AppLanguage.es: 'En ritmo',
      AppLanguage.en: 'Flowing',
    },
    'statusWaiting': {
      AppLanguage.ca: 'Esperant',
      AppLanguage.es: 'Esperando',
      AppLanguage.en: 'Waiting',
    },
    'statusCritical': {
      AppLanguage.ca: 'Atencio',
      AppLanguage.es: 'Atencion',
      AppLanguage.en: 'Needs attention',
    },
    'readyPickup': {
      AppLanguage.ca: 'Recollida',
      AppLanguage.es: 'Recogida',
      AppLanguage.en: 'Pickup',
    },
    'priority': {
      AppLanguage.ca: 'Prioritari',
      AppLanguage.es: 'Prioritario',
      AppLanguage.en: 'Priority',
    },
  };

  static String t(AppLanguage language, String key) {
    return _values[key]?[language] ?? _values[key]?[AppLanguage.en] ?? key;
  }
}

class LocalizedCopy {
  const LocalizedCopy({required this.ca, required this.es, required this.en});

  final String ca;
  final String es;
  final String en;

  String text(AppLanguage language) {
    switch (language) {
      case AppLanguage.ca:
        return ca;
      case AppLanguage.es:
        return es;
      case AppLanguage.en:
        return en;
    }
  }
}

enum OrderStage { fresh, cooking, ready }

enum TableShape { square, round }

enum TableMood { seated, flowing, waiting, critical }

enum NexusGlyphType {
  revenue,
  ticket,
  table,
  timer,
  floor,
  orders,
  insight,
  language,
  pulse,
  flame,
  check,
  grip,
}

class KpiMetric {
  const KpiMetric({
    required this.labelKey,
    required this.value,
    required this.delta,
    required this.captionKey,
    required this.positive,
    required this.glyph,
    required this.accent,
  });

  final String labelKey;
  final String value;
  final String delta;
  final String captionKey;
  final bool positive;
  final NexusGlyphType glyph;
  final Color accent;
}

class FloorTable {
  const FloorTable({
    required this.number,
    required this.seats,
    required this.mood,
    required this.shape,
    required this.waitMinutes,
  });

  final int number;
  final int seats;
  final TableMood mood;
  final TableShape shape;
  final int waitMinutes;
}

class OrderLine {
  const OrderLine({required this.quantity, required this.name});

  final int quantity;
  final LocalizedCopy name;
}

class LiveOrder {
  const LiveOrder({
    required this.id,
    required this.tableNumber,
    required this.guests,
    required this.lines,
    required this.total,
    required this.elapsedMinutes,
    required this.stage,
    this.priority = false,
  });

  final String id;
  final int tableNumber;
  final int guests;
  final List<OrderLine> lines;
  final double total;
  final int elapsedMinutes;
  final OrderStage stage;
  final bool priority;

  LiveOrder copyWith({OrderStage? stage, int? elapsedMinutes}) {
    return LiveOrder(
      id: id,
      tableNumber: tableNumber,
      guests: guests,
      lines: lines,
      total: total,
      elapsedMinutes: elapsedMinutes ?? this.elapsedMinutes,
      stage: stage ?? this.stage,
      priority: priority,
    );
  }
}

class MockData {
  static List<KpiMetric> metrics(AppLanguage language) {
    return [
      KpiMetric(
        labelKey: 'revenueToday',
        value: formatCurrency(1452.80, language),
        delta: '+12.4%',
        captionKey: 'vsYesterday',
        positive: true,
        glyph: NexusGlyphType.revenue,
        accent: NexusColors.accentGreen,
      ),
      KpiMetric(
        labelKey: 'averageTicket',
        value: formatCurrency(38.70, language),
        delta: '+3.1%',
        captionKey: 'vsYesterday',
        positive: true,
        glyph: NexusGlyphType.ticket,
        accent: NexusColors.accentViolet,
      ),
      const KpiMetric(
        labelKey: 'activeTables',
        value: '18 / 24',
        delta: '+4',
        captionKey: 'coverage',
        positive: true,
        glyph: NexusGlyphType.table,
        accent: NexusColors.accentBlue,
      ),
      const KpiMetric(
        labelKey: 'averageWait',
        value: '11 min',
        delta: '-2 min',
        captionKey: 'lowerIsBetter',
        positive: true,
        glyph: NexusGlyphType.timer,
        accent: NexusColors.accentAmber,
      ),
    ];
  }

  static List<FloorTable> tables() {
    return const [
      FloorTable(
        number: 1,
        seats: 2,
        mood: TableMood.flowing,
        shape: TableShape.round,
        waitMinutes: 8,
      ),
      FloorTable(
        number: 2,
        seats: 4,
        mood: TableMood.seated,
        shape: TableShape.square,
        waitMinutes: 3,
      ),
      FloorTable(
        number: 3,
        seats: 4,
        mood: TableMood.flowing,
        shape: TableShape.square,
        waitMinutes: 10,
      ),
      FloorTable(
        number: 4,
        seats: 2,
        mood: TableMood.waiting,
        shape: TableShape.round,
        waitMinutes: 18,
      ),
      FloorTable(
        number: 5,
        seats: 6,
        mood: TableMood.critical,
        shape: TableShape.square,
        waitMinutes: 24,
      ),
      FloorTable(
        number: 6,
        seats: 2,
        mood: TableMood.flowing,
        shape: TableShape.round,
        waitMinutes: 7,
      ),
      FloorTable(
        number: 7,
        seats: 4,
        mood: TableMood.seated,
        shape: TableShape.square,
        waitMinutes: 4,
      ),
      FloorTable(
        number: 8,
        seats: 8,
        mood: TableMood.flowing,
        shape: TableShape.square,
        waitMinutes: 13,
      ),
      FloorTable(
        number: 9,
        seats: 4,
        mood: TableMood.waiting,
        shape: TableShape.round,
        waitMinutes: 21,
      ),
      FloorTable(
        number: 10,
        seats: 2,
        mood: TableMood.flowing,
        shape: TableShape.round,
        waitMinutes: 9,
      ),
      FloorTable(
        number: 11,
        seats: 6,
        mood: TableMood.critical,
        shape: TableShape.square,
        waitMinutes: 27,
      ),
      FloorTable(
        number: 12,
        seats: 4,
        mood: TableMood.flowing,
        shape: TableShape.square,
        waitMinutes: 12,
      ),
      FloorTable(
        number: 13,
        seats: 2,
        mood: TableMood.seated,
        shape: TableShape.round,
        waitMinutes: 2,
      ),
      FloorTable(
        number: 14,
        seats: 4,
        mood: TableMood.flowing,
        shape: TableShape.square,
        waitMinutes: 14,
      ),
      FloorTable(
        number: 15,
        seats: 4,
        mood: TableMood.waiting,
        shape: TableShape.square,
        waitMinutes: 19,
      ),
      FloorTable(
        number: 16,
        seats: 6,
        mood: TableMood.flowing,
        shape: TableShape.round,
        waitMinutes: 11,
      ),
      FloorTable(
        number: 17,
        seats: 2,
        mood: TableMood.seated,
        shape: TableShape.round,
        waitMinutes: 5,
      ),
      FloorTable(
        number: 18,
        seats: 4,
        mood: TableMood.critical,
        shape: TableShape.square,
        waitMinutes: 31,
      ),
      FloorTable(
        number: 19,
        seats: 8,
        mood: TableMood.flowing,
        shape: TableShape.square,
        waitMinutes: 15,
      ),
      FloorTable(
        number: 20,
        seats: 2,
        mood: TableMood.flowing,
        shape: TableShape.round,
        waitMinutes: 6,
      ),
      FloorTable(
        number: 21,
        seats: 4,
        mood: TableMood.waiting,
        shape: TableShape.square,
        waitMinutes: 22,
      ),
      FloorTable(
        number: 22,
        seats: 6,
        mood: TableMood.flowing,
        shape: TableShape.round,
        waitMinutes: 12,
      ),
      FloorTable(
        number: 23,
        seats: 4,
        mood: TableMood.seated,
        shape: TableShape.square,
        waitMinutes: 1,
      ),
      FloorTable(
        number: 24,
        seats: 2,
        mood: TableMood.flowing,
        shape: TableShape.round,
        waitMinutes: 9,
      ),
    ];
  }

  static List<LiveOrder> orders() {
    return const [
      LiveOrder(
        id: 'N-1048',
        tableNumber: 4,
        guests: 2,
        elapsedMinutes: 4,
        total: 42.50,
        stage: OrderStage.fresh,
        priority: true,
        lines: [
          OrderLine(
            quantity: 2,
            name: LocalizedCopy(
              ca: 'Burger trufada',
              es: 'Burger trufada',
              en: 'Truffled burger',
            ),
          ),
          OrderLine(
            quantity: 1,
            name: LocalizedCopy(
              ca: 'Patates braves',
              es: 'Patatas bravas',
              en: 'Patatas bravas',
            ),
          ),
          OrderLine(
            quantity: 2,
            name: LocalizedCopy(
              ca: 'IPA artesanal',
              es: 'IPA artesanal',
              en: 'Craft IPA',
            ),
          ),
        ],
      ),
      LiveOrder(
        id: 'N-1049',
        tableNumber: 11,
        guests: 6,
        elapsedMinutes: 9,
        total: 96.40,
        stage: OrderStage.fresh,
        lines: [
          OrderLine(
            quantity: 3,
            name: LocalizedCopy(
              ca: 'Tacos de cochinita',
              es: 'Tacos de cochinita',
              en: 'Cochinita tacos',
            ),
          ),
          OrderLine(
            quantity: 2,
            name: LocalizedCopy(
              ca: 'Amanida de burrata',
              es: 'Ensalada de burrata',
              en: 'Burrata salad',
            ),
          ),
          OrderLine(
            quantity: 1,
            name: LocalizedCopy(
              ca: 'Ribeye 400 g',
              es: 'Ribeye 400 g',
              en: 'Ribeye 400 g',
            ),
          ),
        ],
      ),
      LiveOrder(
        id: 'N-1050',
        tableNumber: 2,
        guests: 4,
        elapsedMinutes: 12,
        total: 68.20,
        stage: OrderStage.cooking,
        lines: [
          OrderLine(
            quantity: 2,
            name: LocalizedCopy(
              ca: 'Risotto de ceps',
              es: 'Risotto de setas',
              en: 'Wild mushroom risotto',
            ),
          ),
          OrderLine(
            quantity: 1,
            name: LocalizedCopy(
              ca: 'Pop a la brasa',
              es: 'Pulpo a la brasa',
              en: 'Charred octopus',
            ),
          ),
          OrderLine(
            quantity: 2,
            name: LocalizedCopy(
              ca: 'Llimonada de roman',
              es: 'Limonada de romero',
              en: 'Rosemary lemonade',
            ),
          ),
        ],
      ),
      LiveOrder(
        id: 'N-1051',
        tableNumber: 9,
        guests: 4,
        elapsedMinutes: 18,
        total: 74.90,
        stage: OrderStage.cooking,
        priority: true,
        lines: [
          OrderLine(
            quantity: 1,
            name: LocalizedCopy(
              ca: 'Arros melos de gamba',
              es: 'Arroz meloso de gamba',
              en: 'Prawn creamy rice',
            ),
          ),
          OrderLine(
            quantity: 2,
            name: LocalizedCopy(
              ca: 'Croquetes de pernil',
              es: 'Croquetas de jamon',
              en: 'Iberian ham croquettes',
            ),
          ),
          OrderLine(
            quantity: 1,
            name: LocalizedCopy(
              ca: 'Tarta fina de poma',
              es: 'Tarta fina de manzana',
              en: 'Thin apple tart',
            ),
          ),
        ],
      ),
      LiveOrder(
        id: 'N-1052',
        tableNumber: 16,
        guests: 6,
        elapsedMinutes: 15,
        total: 121.10,
        stage: OrderStage.cooking,
        lines: [
          OrderLine(
            quantity: 2,
            name: LocalizedCopy(
              ca: 'Peix del dia',
              es: 'Pescado del dia',
              en: 'Catch of the day',
            ),
          ),
          OrderLine(
            quantity: 2,
            name: LocalizedCopy(
              ca: 'Steak tartar',
              es: 'Steak tartar',
              en: 'Steak tartare',
            ),
          ),
          OrderLine(
            quantity: 1,
            name: LocalizedCopy(
              ca: 'Verdures escalivades',
              es: 'Verduras asadas',
              en: 'Roasted vegetables',
            ),
          ),
        ],
      ),
      LiveOrder(
        id: 'N-1053',
        tableNumber: 7,
        guests: 4,
        elapsedMinutes: 21,
        total: 55.30,
        stage: OrderStage.ready,
        lines: [
          OrderLine(
            quantity: 2,
            name: LocalizedCopy(
              ca: 'Canelons de rostit',
              es: 'Canelones de rustido',
              en: 'Roast cannelloni',
            ),
          ),
          OrderLine(
            quantity: 1,
            name: LocalizedCopy(
              ca: 'Brioix de costella',
              es: 'Brioche de costilla',
              en: 'Short rib brioche',
            ),
          ),
          OrderLine(
            quantity: 2,
            name: LocalizedCopy(
              ca: 'Cafe fred',
              es: 'Cafe frio',
              en: 'Cold brew',
            ),
          ),
        ],
      ),
      LiveOrder(
        id: 'N-1054',
        tableNumber: 18,
        guests: 4,
        elapsedMinutes: 24,
        total: 88.60,
        stage: OrderStage.ready,
        priority: true,
        lines: [
          OrderLine(
            quantity: 1,
            name: LocalizedCopy(
              ca: 'Llobarro a la sal',
              es: 'Lubina a la sal',
              en: 'Salt baked sea bass',
            ),
          ),
          OrderLine(
            quantity: 2,
            name: LocalizedCopy(
              ca: 'Carxofes confitades',
              es: 'Alcachofas confitadas',
              en: 'Confit artichokes',
            ),
          ),
          OrderLine(
            quantity: 2,
            name: LocalizedCopy(
              ca: 'Copa de cava brut',
              es: 'Copa de cava brut',
              en: 'Brut cava glass',
            ),
          ),
        ],
      ),
    ];
  }
}

String formatCurrency(double value, AppLanguage language) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final separator = language == AppLanguage.en ? ',' : '.';
  final decimal = language == AppLanguage.en ? '.' : ',';
  final chars = parts.first.split('').reversed.toList();
  final buffer = StringBuffer();
  for (var i = 0; i < chars.length; i++) {
    if (i > 0 && i % 3 == 0) buffer.write(separator);
    buffer.write(chars[i]);
  }
  final whole = buffer.toString().split('').reversed.join();
  return '$whole$decimal${parts.last} EUR';
}

String stageLabel(AppLanguage language, OrderStage stage) {
  switch (stage) {
    case OrderStage.fresh:
      return L10n.t(language, 'stageNew');
    case OrderStage.cooking:
      return L10n.t(language, 'stageCooking');
    case OrderStage.ready:
      return L10n.t(language, 'stageReady');
  }
}

Color stageColor(OrderStage stage) {
  switch (stage) {
    case OrderStage.fresh:
      return NexusColors.accentBlue;
    case OrderStage.cooking:
      return NexusColors.accentAmber;
    case OrderStage.ready:
      return NexusColors.accentGreen;
  }
}

String tableMoodLabel(AppLanguage language, TableMood mood) {
  switch (mood) {
    case TableMood.seated:
      return L10n.t(language, 'statusSeated');
    case TableMood.flowing:
      return L10n.t(language, 'statusFlowing');
    case TableMood.waiting:
      return L10n.t(language, 'statusWaiting');
    case TableMood.critical:
      return L10n.t(language, 'statusCritical');
  }
}

Color tableMoodColor(TableMood mood) {
  switch (mood) {
    case TableMood.seated:
      return NexusColors.accentBlue;
    case TableMood.flowing:
      return NexusColors.textMuted;
    case TableMood.waiting:
      return NexusColors.accentAmber;
    case TableMood.critical:
      return NexusColors.accentRed;
  }
}

class LiveViewScreen extends StatefulWidget {
  const LiveViewScreen({required this.controller, super.key});

  final LocaleController controller;

  @override
  State<LiveViewScreen> createState() => _LiveViewScreenState();
}

class _LiveViewScreenState extends State<LiveViewScreen> {
  late List<LiveOrder> _orders;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _orders = MockData.orders();
  }

  void _moveOrder(LiveOrder order, OrderStage stage) {
    setState(() {
      final index = _orders.indexWhere((item) => item.id == order.id);
      if (index == -1) return;
      _orders[index] = _orders[index].copyWith(stage: stage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final language = widget.controller.language;
        return LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 780;
            return Scaffold(
              backgroundColor: NexusColors.background,
              bottomNavigationBar: compact
                  ? NexusBottomNavigation(
                      selectedIndex: _navIndex,
                      language: language,
                      onChanged: (value) => setState(() => _navIndex = value),
                    )
                  : null,
              body: Column(
                children: [
                  const DesktopTitleBar(),
                  Expanded(
                    child: SafeArea(
                      bottom: !compact,
                      child: Row(
                        children: [
                          if (!compact)
                            NexusNavigationRail(
                              selectedIndex: _navIndex,
                              language: language,
                              onChanged: (value) => setState(() => _navIndex = value),
                            ),
                          Expanded(
                            child: Column(
                              children: [
                                NexusTopBar(
                                  language: language,
                                  onLanguageChanged: widget.controller.setLanguage,
                                ),
                                Expanded(
                                  child: LiveDashboard(
                                    language: language,
                                    orders: _orders,
                                    onOrderStageChanged: _moveOrder,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class DesktopTitleBar extends StatelessWidget {
  const DesktopTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) return const SizedBox.shrink();
    return const SizedBox(
      height: 32,
      child: WindowCaption(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

class NexusNotification {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => DesktopNotification(
        message: message,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class DesktopNotification extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const DesktopNotification({required this.message, required this.onDismiss, super.key});

  @override
  State<DesktopNotification> createState() => _DesktopNotificationState();
}

class _DesktopNotificationState extends State<DesktopNotification> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => setState(() => _visible = true));
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _visible = false);
        Future.delayed(const Duration(milliseconds: 300), widget.onDismiss);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      bottom: _visible ? 32 : -100,
      right: 32,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: NexusColors.panelHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexusColors.borderBright),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline, color: NexusColors.accentGreen, size: 20),
              const SizedBox(width: 12),
              Text(
                widget.message,
                style: const TextStyle(
                  color: NexusColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LiveDashboard extends StatelessWidget {
  const LiveDashboard({
    required this.language,
    required this.orders,
    required this.onOrderStageChanged,
    super.key,
  });

  final AppLanguage language;
  final List<LiveOrder> orders;
  final void Function(LiveOrder order, OrderStage stage) onOrderStageChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1160;
        final compact = constraints.maxWidth < 760;
        final padding = EdgeInsets.fromLTRB(
          compact ? 16 : 24,
          14,
          compact ? 16 : 24,
          compact ? 92 : 24,
        );

        if (wide) {
          final panelHeight = math.max(520.0, constraints.maxHeight - 164);
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: padding,
            child: Column(
              children: [
                KpiStrip(language: language),
                const SizedBox(height: 18),
                SizedBox(
                  height: panelHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 5,
                        child: ThermalTableMap(
                          language: language,
                          fillHeight: true,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 4,
                        child: OperativeKanban(
                          language: language,
                          orders: orders,
                          onOrderStageChanged: onOrderStageChanged,
                          fillHeight: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: padding,
          children: [
            KpiStrip(language: language),
            const SizedBox(height: 16),
            ThermalTableMap(language: language),
            const SizedBox(height: 16),
            OperativeKanban(
              language: language,
              orders: orders,
              onOrderStageChanged: onOrderStageChanged,
            ),
          ],
        );
      },
    );
  }
}

class NexusTopBar extends StatelessWidget {
  const NexusTopBar({
    required this.language,
    required this.onLanguageChanged,
    super.key,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(
        color: NexusColors.background,
        border: Border(bottom: BorderSide(color: NexusColors.border, width: 1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 540;
          return Row(
            children: [
              const NexusWordmark(),
              const SizedBox(width: 16),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: compact
                      ? const SizedBox.shrink(key: ValueKey('compact-title'))
                      : Column(
                          key: ValueKey('title-${language.code}'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              L10n.t(language, 'appSubtitle'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: NexusColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                            const SizedBox(height: 5),
                            LiveSyncLabel(language: language),
                          ],
                        ),
                ),
              ),
              LanguageSegmentedControl(
                language: language,
                onChanged: onLanguageChanged,
              ),
            ],
          );
        },
      ),
    );
  }
}

class NexusWordmark extends StatelessWidget {
  const NexusWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: NexusColors.borderBright),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF202020), Color(0xFF141414)],
            ),
            boxShadow: [
              BoxShadow(
                color: NexusColors.accentGreen.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'N',
              style: TextStyle(
                color: NexusColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 17,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'NEXUS',
          style: TextStyle(
            color: NexusColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 15,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class LiveSyncLabel extends StatefulWidget {
  const LiveSyncLabel({required this.language, super.key});

  final AppLanguage language;

  @override
  State<LiveSyncLabel> createState() => _LiveSyncLabelState();
}

class _LiveSyncLabelState extends State<LiveSyncLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: Tween<double>(begin: 0.35, end: 1).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: NexusColors.accentGreen,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          L10n.t(widget.language, 'synced'),
          style: const TextStyle(
            color: NexusColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class LanguageSegmentedControl extends StatelessWidget {
  const LanguageSegmentedControl({
    required this.language,
    required this.onChanged,
    super.key,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: L10n.t(language, 'language'),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: NexusColors.panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NexusColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: AppLanguage.values.map((item) {
            final selected = item == language;
            return Semantics(
              button: true,
              selected: selected,
              label: item.semanticName,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                splashColor: NexusColors.accentGreen.withValues(alpha: 0.08),
                onTap: () => onChanged(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 210),
                  curve: Curves.easeOutCubic,
                  width: 42,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? NexusColors.textPrimary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? NexusColors.borderBright
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    item.code,
                    style: TextStyle(
                      color: selected
                          ? NexusColors.textPrimary
                          : NexusColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NexusNavigationRail extends StatelessWidget {
  const NexusNavigationRail({
    required this.selectedIndex,
    required this.language,
    required this.onChanged,
    super.key,
  });

  final int selectedIndex;
  final AppLanguage language;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem('navLive', NexusGlyphType.pulse),
      _NavItem('navFloor', NexusGlyphType.floor),
      _NavItem('navKitchen', NexusGlyphType.orders),
      _NavItem('navInsights', NexusGlyphType.insight),
    ];

    return Container(
      width: 96,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      decoration: const BoxDecoration(
        color: NexusColors.backgroundElevated,
        border: Border(right: BorderSide(color: NexusColors.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),
          for (var i = 0; i < items.length; i++) ...[
            NexusNavButton(
              label: L10n.t(language, items[i].labelKey),
              glyph: items[i].glyph,
              selected: selectedIndex == i,
              onTap: () => onChanged(i),
            ),
            if (i != items.length - 1) const SizedBox(height: 12),
          ],
          const Spacer(),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: NexusColors.border),
              color: NexusColors.panel,
            ),
            child: const NexusGlyph(
              type: NexusGlyphType.language,
              color: NexusColors.textMuted,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class NexusBottomNavigation extends StatelessWidget {
  const NexusBottomNavigation({
    required this.selectedIndex,
    required this.language,
    required this.onChanged,
    super.key,
  });

  final int selectedIndex;
  final AppLanguage language;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem('navLive', NexusGlyphType.pulse),
      _NavItem('navFloor', NexusGlyphType.floor),
      _NavItem('navKitchen', NexusGlyphType.orders),
      _NavItem('navInsights', NexusGlyphType.insight),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: NexusColors.panel,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: NexusColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: NexusBottomNavButton(
                  label: L10n.t(language, items[i].labelKey),
                  glyph: items[i].glyph,
                  selected: selectedIndex == i,
                  onTap: () => onChanged(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.labelKey, this.glyph);

  final String labelKey;
  final NexusGlyphType glyph;
}

class NexusNavButton extends StatelessWidget {
  const NexusNavButton({
    required this.label,
    required this.glyph,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final NexusGlyphType glyph;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      splashColor: NexusColors.accentGreen.withValues(alpha: 0.08),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? NexusColors.panel : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? NexusColors.borderBright : Colors.transparent,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NexusGlyph(
              type: glyph,
              size: 20,
              color: selected ? NexusColors.textPrimary : NexusColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    selected ? NexusColors.textPrimary : NexusColors.textMuted,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NexusBottomNavButton extends StatelessWidget {
  const NexusBottomNavButton({
    required this.label,
    required this.glyph,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final NexusGlyphType glyph;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      splashColor: NexusColors.accentGreen.withValues(alpha: 0.08),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? NexusColors.backgroundElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? NexusColors.borderBright : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NexusGlyph(
              type: glyph,
              size: 18,
              color: selected ? NexusColors.textPrimary : NexusColors.textMuted,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    selected ? NexusColors.textPrimary : NexusColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KpiStrip extends StatelessWidget {
  const KpiStrip({required this.language, super.key});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final metrics = MockData.metrics(language);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;
        if (compact) {
          return SizedBox(
            height: 154,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => SizedBox(
                width: 228,
                child: EntranceMotion(
                  index: index,
                  child: KpiCard(metric: metrics[index], language: language),
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: metrics.length,
            ),
          );
        }

        return Row(
          children: [
            for (var i = 0; i < metrics.length; i++) ...[
              Expanded(
                child: EntranceMotion(
                  index: i,
                  child: KpiCard(metric: metrics[i], language: language),
                ),
              ),
              if (i != metrics.length - 1) const SizedBox(width: 14),
            ],
          ],
        );
      },
    );
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({required this.metric, required this.language, super.key});

  final KpiMetric metric;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: NexusColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NexusColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: metric.accent.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(13),
                  border:
                      Border.all(color: metric.accent.withValues(alpha: 0.22)),
                ),
                child: NexusGlyph(
                  type: metric.glyph,
                  color: metric.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    L10n.t(language, metric.labelKey),
                    key: ValueKey('${language.code}-${metric.labelKey}'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NexusColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: NexusColors.textPrimary,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: metric.positive
                      ? NexusColors.accentGreen.withValues(alpha: 0.10)
                      : NexusColors.accentRed.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: metric.positive
                        ? NexusColors.accentGreen.withValues(alpha: 0.24)
                        : NexusColors.accentRed.withValues(alpha: 0.24),
                  ),
                ),
                child: Text(
                  metric.delta,
                  style: TextStyle(
                    color: metric.positive
                        ? NexusColors.accentGreen
                        : NexusColors.accentRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  L10n.t(language, metric.captionKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: NexusColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ThermalTableMap extends StatelessWidget {
  const ThermalTableMap({
    required this.language,
    this.fillHeight = false,
    super.key,
  });

  final AppLanguage language;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    final tables = MockData.tables();
    return NexusPanel(
      title: L10n.t(language, 'floorMap'),
      glyph: NexusGlyphType.floor,
      accent: NexusColors.accentBlue,
      expandChild: fillHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 620 ? 6 : 4;
          return GridView.builder(
            physics: fillHeight
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            shrinkWrap: !fillHeight,
            itemCount: tables.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: columns == 6 ? 1.05 : 0.98,
            ),
            itemBuilder: (context, index) {
              return EntranceMotion(
                index: index,
                child: TableTile(table: tables[index], language: language),
              );
            },
          );
        },
      ),
    );
  }
}

class TableTile extends StatefulWidget {
  const TableTile({required this.table, required this.language, super.key});

  final FloorTable table;
  final AppLanguage language;

  @override
  State<TableTile> createState() => _TableTileState();
}

class _TableTileState extends State<TableTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = tableMoodColor(widget.table.mood);
    final critical = widget.table.mood == TableMood.critical;
    final waiting = widget.table.mood == TableMood.waiting;
    final seated = widget.table.mood == TableMood.seated;
    final shape = widget.table.shape == TableShape.round;
    final status = tableMoodLabel(widget.language, widget.table.mood);
    final borderRadius = BorderRadius.circular(shape ? 999 : 18);

    return Semantics(
      button: true,
      label:
          '${L10n.t(widget.language, 'table')} ${widget.table.number}, $status',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: shape ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: shape ? null : borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(
                    alpha: critical
                        ? 0.22
                        : waiting
                            ? 0.16
                            : seated
                                ? 0.13
                                : 0.05,
                  ),
                  NexusColors.panelHigh,
                ],
              ),
              border: Border.all(
                color: accent.withValues(
                  alpha: critical
                      ? 0.65
                      : waiting || seated
                          ? 0.42
                          : 0.18,
                ),
                width: critical ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: critical ? 0.18 : 0.08),
                  blurRadius: critical ? 22 : 14,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.table.number}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NexusColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.table.seats} ${L10n.t(widget.language, 'covers')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NexusColors.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${widget.table.waitMinutes} ${L10n.t(widget.language, 'min')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent == NexusColors.textMuted
                            ? NexusColors.textSecondary
                            : accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OperativeKanban extends StatelessWidget {
  const OperativeKanban({
    required this.language,
    required this.orders,
    required this.onOrderStageChanged,
    this.fillHeight = false,
    super.key,
  });

  final AppLanguage language;
  final List<LiveOrder> orders;
  final void Function(LiveOrder order, OrderStage stage) onOrderStageChanged;
  final bool fillHeight;

  @override
  Widget build(BuildContext context) {
    return NexusPanel(
      title: L10n.t(language, 'liveOrders'),
      glyph: NexusGlyphType.orders,
      accent: NexusColors.accentAmber,
      expandChild: fillHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight =
              constraints.maxHeight.isFinite ? constraints.maxHeight : 520.0;
          final height = fillHeight ? availableHeight : 520.0;
          final columnWidth = constraints.maxWidth >= 920
              ? math.max(252.0, (constraints.maxWidth - 28) / 3)
              : 284.0;

          return SizedBox(
            height: height,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final stage in OrderStage.values) ...[
                    SizedBox(
                      width: columnWidth,
                      child: OrderColumn(
                        stage: stage,
                        language: language,
                        orders: orders
                            .where((order) => order.stage == stage)
                            .toList(growable: false),
                        onOrderStageChanged: onOrderStageChanged,
                      ),
                    ),
                    if (stage != OrderStage.values.last)
                      const SizedBox(width: 14),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class OrderColumn extends StatelessWidget {
  const OrderColumn({
    required this.stage,
    required this.language,
    required this.orders,
    required this.onOrderStageChanged,
    super.key,
  });

  final OrderStage stage;
  final AppLanguage language;
  final List<LiveOrder> orders;
  final void Function(LiveOrder order, OrderStage stage) onOrderStageChanged;

  @override
  Widget build(BuildContext context) {
    final accent = stageColor(stage);
    return DragTarget<LiveOrder>(
      onWillAcceptWithDetails: (details) => details.data.stage != stage,
      onAcceptWithDetails: (details) =>
          onOrderStageChanged(details.data, stage),
      builder: (context, candidateData, rejectedData) {
        final active = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active
                ? accent.withValues(alpha: 0.10)
                : NexusColors.backgroundElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  active ? accent.withValues(alpha: 0.48) : NexusColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.24),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        stageLabel(language, stage),
                        key: ValueKey('${language.code}-$stage'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: NexusColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  CountPill(count: orders.length, accent: accent),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: orders.isEmpty
                    ? EmptyColumn(language: language)
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return EntranceMotion(
                            index: index,
                            child: OrderCard(order: order, language: language),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CountPill extends StatelessWidget {
  const CountPill({required this.count, required this.accent, super.key});

  final int count;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: accent,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class EmptyColumn extends StatelessWidget {
  const EmptyColumn({required this.language, super.key});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        L10n.t(language, 'noOrders'),
        style: const TextStyle(
          color: NexusColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({required this.order, required this.language, super.key});

  final LiveOrder order;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final accent = stageColor(order.stage);
    final child = _OrderCardSurface(
      order: order,
      language: language,
      accent: accent,
    );

    return LongPressDraggable<LiveOrder>(
      data: order,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 284,
          child: Transform.rotate(angle: -0.018, child: child),
        ),
      ),
      childWhenDragging: AnimatedOpacity(
        opacity: 0.35,
        duration: const Duration(milliseconds: 160),
        child: child,
      ),
      child: child,
    );
  }
}

class _OrderCardSurface extends StatelessWidget {
  const _OrderCardSurface({
    required this.order,
    required this.language,
    required this.accent,
  });

  final LiveOrder order;
  final AppLanguage language;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final title = '${L10n.t(language, 'table')} ${order.tableNumber}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: accent.withValues(alpha: 0.08),
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NexusColors.panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: order.priority
                  ? NexusColors.accentRed.withValues(alpha: 0.46)
                  : NexusColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: NexusColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  NexusGlyph(
                    type: NexusGlyphType.grip,
                    color: NexusColors.textMuted,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Text(
                    order.id,
                    style: const TextStyle(
                      color: NexusColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Dot(color: NexusColors.borderBright),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${order.guests} ${L10n.t(language, 'guests')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: NexusColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              for (final line in order.lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${line.quantity}x ${line.name.text(language)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NexusColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formatCurrency(order.total, language),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: NexusColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  if (order.priority) ...[
                    StatusChip(
                      text: L10n.t(language, 'priority'),
                      color: NexusColors.accentRed,
                    ),
                    const SizedBox(width: 8),
                  ],
                  StatusChip(
                    text: '${order.elapsedMinutes} ${L10n.t(language, 'min')}',
                    color: accent,
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

class StatusChip extends StatelessWidget {
  const StatusChip({required this.text, required this.color, super.key});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class NexusPanel extends StatelessWidget {
  const NexusPanel({
    required this.title,
    required this.glyph,
    required this.accent,
    required this.child,
    this.expandChild = false,
    super.key,
  });

  final String title;
  final NexusGlyphType glyph;
  final Color accent;
  final Widget child;
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexusColors.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: NexusColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: expandChild ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.20)),
                ),
                child: NexusGlyph(type: glyph, color: accent, size: 18),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    title,
                    key: ValueKey(title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: NexusColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (expandChild) Expanded(child: child) else child,
        ],
      ),
    );
  }
}

class EntranceMotion extends StatelessWidget {
  const EntranceMotion({required this.index, required this.child, super.key});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 360 + math.min(index, 10) * 36);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final eased = Curves.easeOutCubic.transform(value);
        return Opacity(
          opacity: eased.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - eased) * 16),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class NexusGlyph extends StatelessWidget {
  const NexusGlyph({
    required this.type,
    required this.color,
    this.size = 22,
    super.key,
  });

  final NexusGlyphType type;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: Size.square(size),
        painter: NexusGlyphPainter(type: type, color: color),
      ),
    );
  }
}

class NexusGlyphPainter extends CustomPainter {
  const NexusGlyphPainter({required this.type, required this.color});

  final NexusGlyphType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, size.width * 0.085)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    switch (type) {
      case NexusGlyphType.revenue:
        canvas.drawCircle(Offset(w * 0.33, h * 0.62), w * 0.18, stroke);
        canvas.drawCircle(Offset(w * 0.56, h * 0.44), w * 0.20, stroke);
        canvas.drawLine(
          Offset(w * 0.18, h * 0.22),
          Offset(w * 0.38, h * 0.12),
          stroke,
        );
        canvas.drawLine(
          Offset(w * 0.38, h * 0.12),
          Offset(w * 0.70, h * 0.20),
          stroke,
        );
        canvas.drawLine(
          Offset(w * 0.70, h * 0.20),
          Offset(w * 0.84, h * 0.10),
          stroke,
        );
        break;
      case NexusGlyphType.ticket:
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.16, h * 0.22, w * 0.68, h * 0.56),
          Radius.circular(w * 0.12),
        );
        canvas.drawRRect(rect, stroke);
        canvas.drawLine(
          Offset(w * 0.34, h * 0.40),
          Offset(w * 0.66, h * 0.40),
          stroke,
        );
        canvas.drawLine(
          Offset(w * 0.34, h * 0.58),
          Offset(w * 0.56, h * 0.58),
          stroke,
        );
        break;
      case NexusGlyphType.table:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.22, h * 0.20, w * 0.56, h * 0.34),
            Radius.circular(w * 0.10),
          ),
          stroke,
        );
        canvas.drawLine(
          Offset(w * 0.32, h * 0.58),
          Offset(w * 0.24, h * 0.82),
          stroke,
        );
        canvas.drawLine(
          Offset(w * 0.68, h * 0.58),
          Offset(w * 0.76, h * 0.82),
          stroke,
        );
        canvas.drawLine(
          Offset(w * 0.50, h * 0.54),
          Offset(w * 0.50, h * 0.82),
          stroke,
        );
        break;
      case NexusGlyphType.timer:
        canvas.drawCircle(Offset(w * 0.50, h * 0.55), w * 0.30, stroke);
        canvas.drawLine(
          Offset(w * 0.50, h * 0.55),
          Offset(w * 0.50, h * 0.36),
          stroke,
        );
        canvas.drawLine(
          Offset(w * 0.50, h * 0.55),
          Offset(w * 0.65, h * 0.62),
          stroke,
        );
        canvas.drawLine(
          Offset(w * 0.40, h * 0.14),
          Offset(w * 0.60, h * 0.14),
          stroke,
        );
        break;
      case NexusGlyphType.floor:
        for (var x = 0; x < 2; x++) {
          for (var y = 0; y < 2; y++) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(
                  w * (0.18 + x * 0.34),
                  h * (0.18 + y * 0.34),
                  w * 0.22,
                  h * 0.22,
                ),
                Radius.circular(w * 0.04),
              ),
              stroke,
            );
          }
        }
        canvas.drawCircle(Offset(w * 0.74, h * 0.74), w * 0.10, stroke);
        break;
      case NexusGlyphType.orders:
        for (var i = 0; i < 3; i++) {
          final y = h * (0.26 + i * 0.22);
          canvas.drawCircle(Offset(w * 0.22, y), w * 0.035, fill);
          canvas.drawLine(Offset(w * 0.36, y), Offset(w * 0.80, y), stroke);
        }
        break;
      case NexusGlyphType.insight:
        canvas.drawLine(
          Offset(w * 0.18, h * 0.78),
          Offset(w * 0.84, h * 0.78),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.24, h * 0.50, w * 0.10, h * 0.28),
            Radius.circular(w * 0.03),
          ),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.46, h * 0.32, w * 0.10, h * 0.46),
            Radius.circular(w * 0.03),
          ),
          stroke,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.68, h * 0.20, w * 0.10, h * 0.58),
            Radius.circular(w * 0.03),
          ),
          stroke,
        );
        break;
      case NexusGlyphType.language:
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.33, stroke);
        canvas.drawLine(
          Offset(w * 0.18, h * 0.50),
          Offset(w * 0.82, h * 0.50),
          stroke,
        );
        canvas.drawArc(
          Rect.fromCircle(center: Offset(w * 0.50, h * 0.50), radius: w * 0.24),
          -math.pi / 2,
          math.pi,
          false,
          stroke,
        );
        canvas.drawArc(
          Rect.fromCircle(center: Offset(w * 0.50, h * 0.50), radius: w * 0.24),
          math.pi / 2,
          math.pi,
          false,
          stroke,
        );
        break;
      case NexusGlyphType.pulse:
        final path = Path()
          ..moveTo(w * 0.13, h * 0.56)
          ..lineTo(w * 0.30, h * 0.56)
          ..lineTo(w * 0.40, h * 0.32)
          ..lineTo(w * 0.54, h * 0.72)
          ..lineTo(w * 0.66, h * 0.46)
          ..lineTo(w * 0.86, h * 0.46);
        canvas.drawPath(path, stroke);
        break;
      case NexusGlyphType.flame:
        final path = Path()
          ..moveTo(w * 0.50, h * 0.86)
          ..cubicTo(w * 0.22, h * 0.70, w * 0.30, h * 0.44, w * 0.50, h * 0.16)
          ..cubicTo(w * 0.74, h * 0.40, w * 0.82, h * 0.64, w * 0.50, h * 0.86);
        canvas.drawPath(path, stroke);
        break;
      case NexusGlyphType.check:
        canvas.drawLine(
          Offset(w * 0.20, h * 0.54),
          Offset(w * 0.42, h * 0.74),
          stroke,
        );
        canvas.drawLine(
          Offset(w * 0.42, h * 0.74),
          Offset(w * 0.82, h * 0.28),
          stroke,
        );
        break;
      case NexusGlyphType.grip:
        for (var x = 0; x < 2; x++) {
          for (var y = 0; y < 3; y++) {
            canvas.drawCircle(
              Offset(w * (0.38 + x * 0.24), h * (0.24 + y * 0.24)),
              w * 0.035,
              fill,
            );
          }
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant NexusGlyphPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}