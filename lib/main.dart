import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'data/local_database.dart';

const Color forest = Color(0xFF173B30);
const Color forestDeep = Color(0xFF10251F);
const Color lime = Color(0xFFC5F36A);
const Color paper = Color(0xFFF5F6F1);
const Color ink = Color(0xFF17231E);
const Color muted = Color(0xFF66736C);
const Color borderColor = Color(0xFFE2E7E0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDatabase.instance.database;
  await AppPreferences.load();
  runApp(const MetBlindFitApp());
}

class AccessibilityPrefs {
  const AccessibilityPrefs({
    this.largeText = false,
    this.highContrast = false,
    this.audioFirst = true,
    this.haptics = true,
  });

  final bool largeText;
  final bool highContrast;
  final bool audioFirst;
  final bool haptics;

  AccessibilityPrefs copyWith({
    bool? largeText,
    bool? highContrast,
    bool? audioFirst,
    bool? haptics,
  }) {
    return AccessibilityPrefs(
      largeText: largeText ?? this.largeText,
      highContrast: highContrast ?? this.highContrast,
      audioFirst: audioFirst ?? this.audioFirst,
      haptics: haptics ?? this.haptics,
    );
  }
}

class AppPreferences {
  static final ValueNotifier<AccessibilityPrefs> current =
      ValueNotifier(const AccessibilityPrefs());

  static Future<void> load() async {
    final values = await LocalDatabase.instance.getPreferences();
    current.value = AccessibilityPrefs(
      largeText: values['large_text'] == 'true',
      highContrast: values['high_contrast'] == 'true',
      audioFirst: values['audio_first'] != 'false',
      haptics: values['haptics'] != 'false',
    );
  }

  static Future<void> update(AccessibilityPrefs prefs) async {
    current.value = prefs;
    await LocalDatabase.instance.setPreference(
      'large_text',
      prefs.largeText.toString(),
    );
    await LocalDatabase.instance.setPreference(
      'high_contrast',
      prefs.highContrast.toString(),
    );
    await LocalDatabase.instance.setPreference(
      'audio_first',
      prefs.audioFirst.toString(),
    );
    await LocalDatabase.instance.setPreference(
      'haptics',
      prefs.haptics.toString(),
    );
  }
}

class MetBlindFitApp extends StatelessWidget {
  const MetBlindFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccessibilityPrefs>(
      valueListenable: AppPreferences.current,
      builder: (context, prefs, _) {
        final background = prefs.highContrast ? Colors.white : paper;
        return MaterialApp(
          title: 'MET Blind Fit',
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(prefs.largeText ? 1.2 : 1.0),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: forest,
              primary: forest,
              secondary: lime,
              surface: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: background,
              foregroundColor: ink,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: borderColor),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                minimumSize: const Size(54, 54),
                backgroundColor: forest,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(52, 52),
                foregroundColor: forest,
                side: const BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          home: const RoleEntryScreen(),
        );
      },
    );
  }
}

enum AppRole { runner, guide, supervisor, admin }

extension AppRoleInfo on AppRole {
  String get label {
    switch (this) {
      case AppRole.runner:
        return 'Corredor invisual / baixa visão';
      case AppRole.guide:
        return 'Guia de corrida';
      case AppRole.supervisor:
        return 'Supervisor';
      case AppRole.admin:
        return 'Administrador (demo)';
    }
  }

  String get shortLabel {
    switch (this) {
      case AppRole.runner:
        return 'corredor';
      case AppRole.guide:
        return 'guia';
      case AppRole.supervisor:
        return 'supervisor';
      case AppRole.admin:
        return 'administrador';
    }
  }

  String get description {
    switch (this) {
      case AppRole.runner:
        return 'Encontra corridas, confirma o acompanhamento e corre em grupo.';
      case AppRole.guide:
        return 'Acompanha corredores e participa em atividades inclusivas.';
      case AppRole.supervisor:
        return 'Confirma presenças, atribuições e estados da sessão.';
      case AppRole.admin:
        return 'Consulta os registos e os fluxos demonstrativos da plataforma.';
    }
  }

  IconData get icon {
    switch (this) {
      case AppRole.runner:
        return Icons.accessibility_new_rounded;
      case AppRole.guide:
        return Icons.directions_run_rounded;
      case AppRole.supervisor:
        return Icons.verified_user_outlined;
      case AppRole.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }
}

class RoleEntryScreen extends StatelessWidget {
  const RoleEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: forest,
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(
                Icons.directions_run_rounded,
                color: lime,
                size: 32,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'MET BLIND FIT',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w900,
                color: forest,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'A corrida é melhor\nquando é partilhada.',
              style: TextStyle(
                fontSize: 35,
                height: 1.04,
                letterSpacing: -1.1,
                fontWeight: FontWeight.w900,
                color: ink,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Corridas inclusivas. Guias de confiança. Grupos com supervisão.',
              style: TextStyle(fontSize: 16, height: 1.45, color: muted),
            ),
            const SizedBox(height: 26),
            for (final role in AppRole.values)
              _RoleTile(
                role: role,
                onTap: () => _confirmRole(context, role),
              ),
            const SizedBox(height: 8),
            const _DemoNotice(
              text:
                  'Protótipo local: perfis e dados são demonstrativos. Ainda não existe verificação real de identidade, GPS, áudio ou serviço de emergência.',
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const AccessibilitySettingsScreen(),
                ),
              ),
              icon: const Icon(Icons.accessibility_new_rounded),
              label: const Text('Configurar acessibilidade'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRole(BuildContext context, AppRole role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Entrar como ${role.shortLabel}?'),
        content: Text(role.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => MainShell(role: role),
        ),
      );
    }
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({required this.role, required this.onTap});

  final AppRole role;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: role.label,
        hint: 'Abre o modo ${role.shortLabel}',
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(19),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1E9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(role.icon, color: forest, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role.description,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: forest,
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

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.role});

  final AppRole role;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  int _refresh = 0;

  void _refreshPages() => setState(() => _refresh++);

  void _openRun(Map<String, Object?> run) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RunDetailScreen(
          run: run,
          onChanged: _refreshPages,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Início', 'Descobrir', 'Comunidade', 'Perfil'];
    final pages = <Widget>[
      HomeTab(
        role: widget.role,
        key: ValueKey('home_$_refresh'),
        onDiscover: () => setState(() => _index = 1),
      ),
      DiscoverTab(
        key: ValueKey('discover_$_refresh'),
        onOpenRun: _openRun,
      ),
      CommunityTab(key: ValueKey('community_$_refresh')),
      ProfileTab(role: widget.role),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: forest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.directions_run_rounded,
                color: lime,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'MET BLIND FIT · ${titles[_index]}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Acessibilidade',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const AccessibilitySettingsScreen(),
              ),
            ),
            icon: const Icon(Icons.accessibility_new_rounded),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Descobrir',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Comunidade',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.role,
    required this.onDiscover,
  });

  final AppRole role;
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: forestDeep,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CORRER JUNTOS',
                style: TextStyle(
                  color: lime,
                  fontSize: 11,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                role == AppRole.supervisor
                    ? 'O grupo começa contigo.'
                    : 'A próxima corrida começa aqui.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                role.description,
                style: const TextStyle(
                  color: Color(0xFFD9E5DD),
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: lime,
                    foregroundColor: forestDeep,
                  ),
                  onPressed: onDiscover,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Encontrar uma corrida'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const _SectionHeading(
          title: 'Feito para correr acompanhado',
          subtitle: 'O essencial, sem complicar.',
        ),
        const SizedBox(height: 12),
        const _InfoCard(
          icon: Icons.verified_user_outlined,
          title: 'Acompanhamento organizado',
          body:
              'Consulta o guia atribuído e o supervisor previsto antes de confirmar a participação.',
        ),
        const _InfoCard(
          icon: Icons.hearing_outlined,
          title: 'Acessibilidade primeiro',
          body:
              'Configura o texto e o contraste. A experiência de áudio real será integrada numa fase posterior.',
        ),
        const _InfoCard(
          icon: Icons.groups_2_outlined,
          title: 'Grupos com um objetivo comum',
          body:
              'Escolhe a distância, o ritmo e o tipo de corrida que melhor se adequam a ti.',
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, Object?>>>(
          future: LocalDatabase.instance.getRuns(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _InlineError(
                message: 'Não foi possível carregar as corridas locais.',
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final runs = snapshot.data!;
            if (runs.isEmpty) {
              return const _EmptyState(
                title: 'Ainda não existem corridas',
                body: 'Volta mais tarde para consultar atividades.',
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeading(
                  title: 'Próximas corridas',
                  subtitle: 'Dados demonstrativos guardados no dispositivo.',
                ),
                const SizedBox(height: 8),
                for (final run in runs.take(2))
                  _RunCard(
                    run: run,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => RunDetailScreen(run: run),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key, required this.onOpenRun});

  final ValueChanged<Map<String, Object?>> onOpenRun;

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  final TextEditingController _search = TextEditingController();
  String _level = 'Todas';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, Object?>>>(
      future: LocalDatabase.instance.getRuns(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const _InlineError(
            message: 'Não foi possível carregar as corridas.',
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final query = _search.text.trim().toLowerCase();
        final runs = snapshot.data!.where((run) {
          final searchable =
              '${run['title']} ${run['city']} ${run['level']} ${run['pace']}'
                  .toLowerCase();
          final matchesQuery = searchable.contains(query);
          final matchesLevel = _level == 'Todas' || run['level'] == _level;
          return matchesQuery && matchesLevel;
        }).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          children: [
            const _SectionHeading(
              title: 'Descobrir corridas',
              subtitle: 'Escolhe uma atividade adequada ao teu ritmo.',
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: 'Pesquisar por nome ou local',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: borderColor),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _level,
              decoration: const InputDecoration(
                labelText: 'Nível',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Todas', child: Text('Todos os níveis')),
                DropdownMenuItem(
                  value: 'Iniciação',
                  child: Text('Iniciação'),
                ),
                DropdownMenuItem(
                  value: 'Primeira corrida',
                  child: Text('Primeira corrida'),
                ),
                DropdownMenuItem(
                  value: 'Intermédio',
                  child: Text('Intermédio'),
                ),
              ],
              onChanged: (value) => setState(() => _level = value ?? 'Todas'),
            ),
            const SizedBox(height: 16),
            Text(
              '${runs.length} ${runs.length == 1 ? 'atividade encontrada' : 'atividades encontradas'}',
              style: const TextStyle(
                color: muted,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (runs.isEmpty)
              const _EmptyState(
                title: 'Não encontrámos resultados',
                body: 'Experimenta outro termo ou nível.',
              ),
            for (final run in runs)
              _RunCard(
                run: run,
                onTap: () => widget.onOpenRun(run),
              ),
          ],
        );
      },
    );
  }
}

class RunDetailScreen extends StatefulWidget {
  const RunDetailScreen({
    super.key,
    required this.run,
    this.onChanged,
  });

  final Map<String, Object?> run;
  final VoidCallback? onChanged;

  @override
  State<RunDetailScreen> createState() => _RunDetailScreenState();
}

class _RunDetailScreenState extends State<RunDetailScreen> {
  bool _busy = false;
  String? _message;

  Future<void> _toggleBooking() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final result = await LocalDatabase.instance.bookRun(widget.run);
      if (!mounted) return;
      setState(() {
        if (result == 'booked') {
          _message = 'Reserva guardada neste dispositivo.';
        } else if (result == 'cancelled') {
          _message = 'Reserva cancelada.';
        } else {
          _message =
              'Esta atividade está cheia. A lista de espera ainda é demonstrativa.';
        }
      });
      widget.onChanged?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'Não foi possível atualizar a reserva.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final run = widget.run;
    final enrolled = run['enrolled'] as int;
    final capacity = run['capacity'] as int;
    final full = run['status'] == 'full' || enrolled >= capacity;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe da corrida')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: forestDeep,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.directions_run_rounded, color: lime, size: 30),
                const SizedBox(height: 14),
                Text(
                  '${run['title']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${run['city']}',
                  style: const TextStyle(color: Color(0xFFD9E5DD)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.calendar_month_outlined,
            title: '${run['date_label']} · ${run['time_label']}',
            subtitle: 'Data e hora de encontro',
          ),
          _DetailRow(
            icon: Icons.route_outlined,
            title: '${run['distance_km']} km · ${run['level']}',
            subtitle: '${run['pace']}',
          ),
          _DetailRow(
            icon: Icons.place_outlined,
            title: '${run['meeting_point']}',
            subtitle: 'Ponto de encontro',
          ),
          _DetailRow(
            icon: Icons.verified_user_outlined,
            title: '${run['supervisor']}',
            subtitle: run['verified'] == 1
                ? 'Supervisor indicado · verificação demonstrativa'
                : 'Supervisor por confirmar',
          ),
          _DetailRow(
            icon: Icons.groups_2_outlined,
            title: '$enrolled de $capacity participantes',
            subtitle: 'Guias previstos: ${run['guides']}',
          ),
          const SizedBox(height: 12),
          const _SectionHeading(
            title: 'Sobre esta corrida',
            subtitle: 'Lê os detalhes antes de reservar.',
          ),
          const SizedBox(height: 8),
          Text(
            '${run['description']}',
            style: const TextStyle(fontSize: 15, height: 1.5, color: muted),
          ),
          const SizedBox(height: 16),
          const _DemoNotice(
            text:
                'Antes de uma corrida real, a organização deve confirmar o percurso, as atribuições de guias e a supervisão. Este protótipo não valida essas condições.',
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            _InlineMessage(message: _message!),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _busy ? null : _toggleBooking,
            icon: Icon(full ? Icons.hourglass_empty : Icons.event_available),
            label: Text(
              _busy
                  ? 'A atualizar...'
                  : full
                      ? 'Consultar lista de espera'
                      : 'Reservar / cancelar reserva',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ActiveRunScreen(),
              ),
            ),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Pré-visualizar corrida ativa'),
          ),
        ],
      ),
    );
  }
}

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  Future<void> _addFriend() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Adicionar amigo/a'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(
            labelText: 'Nome para demonstração',
            hintText: 'Ex.: Alex',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name == null || name.isEmpty) return;
    await LocalDatabase.instance.addFriend(name);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        const _SectionHeading(
          title: 'A tua comunidade',
          subtitle: 'As pessoas com quem podes voltar a correr.',
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 34, color: forest),
                const SizedBox(height: 10),
                const Text(
                  'Liga-te depois da corrida',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mostra o código demonstrativo ou adiciona um nome para testar o fluxo. O QR ainda não representa uma identidade verificada.',
                  style: TextStyle(color: muted, height: 1.4),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: borderColor),
                    ),
                    child: QrImageView(
                      data: 'met-blind-fit://demo/friend/request',
                      version: QrVersions.auto,
                      size: 150,
                      semanticsLabel: 'QR code demonstrativo do MET Blind Fit',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _addFriend,
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Adicionar amigo/a manualmente'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _SectionHeading(
          title: 'Amigos guardados',
          subtitle: 'Lista local deste dispositivo.',
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Map<String, Object?>>>(
          future: LocalDatabase.instance.getFriends(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _InlineError(
                message: 'Não foi possível carregar a lista de amigos.',
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final friends = snapshot.data!;
            if (friends.isEmpty) {
              return const _EmptyState(
                title: 'Ainda não tens amigos guardados',
                body: 'Depois de uma corrida, podes começar por aqui.',
              );
            }
            return Column(
              children: [
                for (final friend in friends)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFEAF1E9),
                        child: Text(
                          '${friend['name']}'.isNotEmpty
                              ? '${friend['name']}'.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: forest,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      title: Text(
                        '${friend['name']}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text('${friend['role']}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        const _SectionHeading(
          title: 'Perfil e preferências',
          subtitle: 'Configura a aplicação para as tuas necessidades.',
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFEAF1E9),
              child: Icon(role.icon, color: forest),
            ),
            title: Text(
              role.label,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: const Text('Perfil local demonstrativo'),
          ),
        ),
        _MenuCard(
          icon: Icons.accessibility_new_rounded,
          title: 'Preferências de acessibilidade',
          subtitle: 'Texto ampliado, contraste e opções áudio-first.',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const AccessibilitySettingsScreen(),
            ),
          ),
        ),
        _MenuCard(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Painel de supervisão',
          subtitle: 'Checklist de participantes e incidentes simulados.',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const SupervisorDashboardScreen(),
            ),
          ),
        ),
        _MenuCard(
          icon: Icons.directions_run_outlined,
          title: 'Corrida ativa demonstrativa',
          subtitle: 'Mapa ilustrativo, estado do sinal e ajuda simulada.',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const ActiveRunScreen(),
            ),
          ),
        ),
        _MenuCard(
          icon: Icons.history_rounded,
          title: 'Registo local',
          subtitle: 'Consulta as últimas ações guardadas.',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const LocalLogScreen(),
            ),
          ),
        ),
        _MenuCard(
          icon: Icons.refresh_rounded,
          title: 'Repor dados demonstrativos',
          subtitle: 'Apaga reservas, amigos e registos locais e repõe exemplos.',
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Repor dados?'),
                content: const Text(
                  'Esta ação apaga as alterações locais de demonstração neste dispositivo.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Repor'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await LocalDatabase.instance.clearDemoData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dados demonstrativos repostos.')),
                );
              }
            }
          },
        ),
        const SizedBox(height: 12),
        const _DemoNotice(
          text:
              'Os estados de verificação, localização e supervisão são exemplos. Não uses esta versão para organizar corridas reais.',
        ),
      ],
    );
  }
}

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  State<SupervisorDashboardScreen> createState() =>
      _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState
    extends State<SupervisorDashboardScreen> {
  final Set<String> _checked = <String>{};
  bool _sessionStarted = false;
  bool _incidentRecorded = false;
  bool _signalLost = false;

  final List<(String, String)> _participants = const [
    ('runner_1', 'Alex · corredor'),
    ('runner_2', 'Joana · corredora'),
    ('runner_3', 'Miguel · corredor'),
    ('guide_1', 'Carlos · guia'),
    ('guide_2', 'Sara · guia'),
    ('guide_3', 'Rui · guia'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Painel do supervisor')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: forestDeep,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SESSÃO DEMONSTRATIVA',
                  style: TextStyle(
                    color: lime,
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Corrida inclusiva à beira-mar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DarkStat(
                        value: '${_checked.length}/${_participants.length}',
                        label: 'Confirmados',
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: _DarkStat(value: '4,0 km', label: 'Percurso'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DarkStat(
                        value: _sessionStarted ? 'Ativa' : 'Por iniciar',
                        label: 'Estado',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionHeading(
            title: 'Checklist de presença',
            subtitle:
                'Confirma cada participante presencialmente e verifica as atribuições.',
          ),
          const SizedBox(height: 8),
          for (final participant in _participants)
            Card(
              child: CheckboxListTile(
                value: _checked.contains(participant.$1),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _checked.add(participant.$1);
                    } else {
                      _checked.remove(participant.$1);
                    }
                  });
                },
                title: Text(
                  participant.$2,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  participant.$1.startsWith('guide_')
                      ? 'Guia · confirmar atribuições'
                      : 'Corredor · confirmar guia atribuído',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: forest,
              ),
            ),
          const SizedBox(height: 12),
          _MenuCard(
            icon: Icons.map_outlined,
            title: 'Estado do percurso',
            subtitle: 'Mapa de teste; GPS real desligado.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const ActiveRunScreen(),
              ),
            ),
          ),
          _MenuCard(
            icon: Icons.signal_wifi_off_rounded,
            title: 'Simular perda de sinal',
            subtitle: _signalLost
                ? 'Sem atualização (simulado).'
                : 'Simula um participante sem atualização de localização.',
            onTap: () => setState(() => _signalLost = !_signalLost),
          ),
          if (_signalLost)
            const _DemoNotice(
              text:
                  'Sem sinal: não assumas que o grupo está seguro. Contacta o guia atribuído e confirma a situação antes de escalar.',
            ),
          _MenuCard(
            icon: Icons.sos_outlined,
            title: 'Incidente / pedido de ajuda',
            subtitle: _incidentRecorded
                ? 'Incidente demonstrativo registado.'
                : 'Regista um incidente fictício para testar o fluxo.',
            onTap: () => setState(() => _incidentRecorded = true),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => setState(() => _sessionStarted = !_sessionStarted),
            icon: Icon(
              _sessionStarted
                  ? Icons.stop_circle_outlined
                  : Icons.play_circle_outline,
            ),
            label: Text(
              _sessionStarted
                  ? 'Terminar sessão demonstrativa'
                  : 'Iniciar sessão demonstrativa',
            ),
          ),
          if (_sessionStarted)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: _DemoNotice(
                text:
                    'Sessão iniciada apenas na interface. Não existe monitorização real nem resposta de emergência integrada.',
              ),
            ),
        ],
      ),
    );
  }
}

class ActiveRunScreen extends StatefulWidget {
  const ActiveRunScreen({super.key});

  @override
  State<ActiveRunScreen> createState() => _ActiveRunScreenState();
}

class _ActiveRunScreenState extends State<ActiveRunScreen> {
  bool _audioEnabled = true;
  bool _helpRequested = false;
  bool _signalAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Corrida ativa · demonstração')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            height: 230,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: forestDeep,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                const Positioned.fill(child: CustomPaint(painter: _RoutePainter())),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'MAPA DEMONSTRATIVO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 18,
                  bottom: 18,
                  child: Text(
                    'Rota ilustrativa · Porto',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Estás acompanhado.',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Guia: Carlos. Supervisora: Marta.',
            style: TextStyle(color: muted, fontSize: 15),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: _MetricBox(
                  icon: Icons.route_outlined,
                  value: '1,2 km',
                  label: 'Percorrido (demo)',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricBox(
                  icon: Icons.timer_outlined,
                  value: '08:42',
                  label: 'Tempo (demo)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            value: _audioEnabled,
            onChanged: (value) => setState(() => _audioEnabled = value),
            activeThumbColor: forest,
            secondary: const Icon(Icons.volume_up_outlined),
            title: const Text(
              'Instruções de áudio',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'Simula a preferência; ainda não reproduz voz real.',
            ),
          ),
          SwitchListTile(
            value: _signalAvailable,
            onChanged: (value) => setState(() => _signalAvailable = value),
            activeThumbColor: forest,
            secondary: Icon(
              _signalAvailable ? Icons.gps_fixed : Icons.gps_off,
            ),
            title: const Text(
              'Sinal de localização',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              _signalAvailable
                  ? 'Sinal demonstrativo disponível'
                  : 'Sem atualização de localização (simulado)',
            ),
          ),
          if (!_signalAvailable)
            const _DemoNotice(
              text:
                  'Sem sinal: mantém-te com o teu guia. O supervisor deve confirmar a situação.',
            ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => setState(() => _helpRequested = !_helpRequested),
            style: FilledButton.styleFrom(
              backgroundColor:
                  _helpRequested ? const Color(0xFF9B2C2C) : forest,
            ),
            icon: const Icon(Icons.sos_rounded),
            label: Text(
              _helpRequested
                  ? 'Pedido de ajuda sinalizado'
                  : 'Pedir ajuda ao supervisor',
            ),
          ),
          if (_helpRequested)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: _DemoNotice(
                text:
                    'Pedido fictício apresentado apenas no ecrã. Não foi enviada mensagem nem contactado qualquer serviço.',
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const AudioDemoScreen(),
              ),
            ),
            icon: const Icon(Icons.record_voice_over_outlined),
            label: const Text('Consultar exemplos de instruções'),
          ),
        ],
      ),
    );
  }
}

class AudioDemoScreen extends StatelessWidget {
  const AudioDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instruções acessíveis')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: const [
          Text(
            'Informação sem depender do mapa',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'Exemplos do tipo de mensagem que a aplicação poderá anunciar. Não é reprodução TTS real.',
            style: TextStyle(color: muted, height: 1.4),
          ),
          SizedBox(height: 16),
          _AudioCard(
            icon: Icons.play_arrow_rounded,
            title: 'Antes de começar',
            text:
                'A corrida tem quatro quilómetros. O teu guia é Carlos e a supervisora é Marta. Confirma que estás com o teu guia antes de iniciar.',
          ),
          _AudioCard(
            icon: Icons.turn_right_rounded,
            title: 'Instrução de percurso',
            text:
                'Daqui a cerca de cem metros, aproxima-se um cruzamento. Mantém-te junto do teu guia e segue as instruções verbais.',
          ),
          _AudioCard(
            icon: Icons.groups_rounded,
            title: 'Grupo a aproximar-se',
            text:
                'O grupo vai reduzir o ritmo no próximo ponto de controlo. Se precisares de parar, informa o teu guia.',
          ),
          _AudioCard(
            icon: Icons.signal_wifi_off_rounded,
            title: 'Sinal perdido',
            text:
                'A localização deixou de atualizar. Mantém-te com o teu guia. O supervisor deverá confirmar a situação.',
          ),
          SizedBox(height: 12),
          _DemoNotice(
            text:
                'As instruções reais dependem de TTS, GPS, desenho de percurso e validação de segurança. Nunca serão substituto do guia humano.',
          ),
        ],
      ),
    );
  }
}

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acessibilidade')),
      body: ValueListenableBuilder<AccessibilityPrefs>(
        valueListenable: AppPreferences.current,
        builder: (context, prefs, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: forestDeep,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.accessibility_new_rounded,
                      color: lime,
                      size: 34,
                    ),
                    SizedBox(height: 14),
                    Text(
                      'A aplicação adapta-se a ti.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Estas preferências ficam guardadas neste dispositivo e podem ser alteradas a qualquer momento.',
                      style: TextStyle(
                        color: Color(0xFFD9E5DD),
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: SwitchListTile(
                  value: prefs.largeText,
                  onChanged: (value) => AppPreferences.update(
                    prefs.copyWith(largeText: value),
                  ),
                  secondary: const Icon(Icons.text_fields_rounded),
                  title: const Text(
                    'Texto ampliado',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Aumenta o tamanho do texto em toda a aplicação.',
                  ),
                ),
              ),
              Card(
                child: SwitchListTile(
                  value: prefs.highContrast,
                  onChanged: (value) => AppPreferences.update(
                    prefs.copyWith(highContrast: value),
                  ),
                  secondary: const Icon(Icons.contrast_rounded),
                  title: const Text(
                    'Fundo de alto contraste',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Usa um fundo branco mais simples para reduzir distrações visuais.',
                  ),
                ),
              ),
              Card(
                child: SwitchListTile(
                  value: prefs.audioFirst,
                  onChanged: (value) => AppPreferences.update(
                    prefs.copyWith(audioFirst: value),
                  ),
                  secondary: const Icon(Icons.record_voice_over_rounded),
                  title: const Text(
                    'Dar prioridade ao áudio',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Guarda a preferência para a futura experiência áudio-first. A voz real ainda não está integrada.',
                  ),
                ),
              ),
              Card(
                child: SwitchListTile(
                  value: prefs.haptics,
                  onChanged: (value) => AppPreferences.update(
                    prefs.copyWith(haptics: value),
                  ),
                  secondary: const Icon(Icons.vibration_rounded),
                  title: const Text(
                    'Preferir sinais táteis',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: const Text(
                    'Guarda a preferência. A vibração contextual ainda não está implementada.',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const _SectionHeading(
                title: 'Pré-visualização',
                subtitle: 'Exemplo de informação relevante para a corrida.',
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: forest,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Guia atribuído',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Carlos acompanha-te nesta corrida. Confirma presencialmente que estão juntos antes de começar.',
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const AudioDemoScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text('Consultar exemplos de instruções'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const _DemoNotice(
                text:
                    'Estas opções não substituem VoiceOver ou TalkBack. A aplicação ainda precisa de testes de acessibilidade com utilizadores cegos e com baixa visão.',
              ),
            ],
          );
        },
      ),
    );
  }
}

class LocalLogScreen extends StatelessWidget {
  const LocalLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registo local')),
      body: FutureBuilder<List<Map<String, Object?>>>(
        future: LocalDatabase.instance.getLog(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _InlineError(
              message: 'Não foi possível carregar o registo.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data!;
          if (entries.isEmpty) {
            return const _EmptyState(
              title: 'Sem atividade registada',
              body: 'As ações locais aparecerão aqui.',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              for (final entry in entries)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.history_rounded, color: forest),
                    title: Text('${entry['message']}'),
                    subtitle: Text('${entry['created_at']}'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RunCard extends StatelessWidget {
  const _RunCard({required this.run, required this.onTap});

  final Map<String, Object?> run;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final enrolled = run['enrolled'] as int;
    final capacity = run['capacity'] as int;
    final full = run['status'] == 'full' || enrolled >= capacity;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1E9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.directions_run_rounded,
                      color: forest,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${run['title']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${run['city']}',
                          style: const TextStyle(color: muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    full ? Icons.hourglass_bottom : Icons.arrow_forward_rounded,
                    color: full ? const Color(0xFF93631C) : forest,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(label: '${run['distance_km']} km'),
                  _Tag(label: '${run['level']}'),
                  _Tag(label: full ? 'Lotação completa' : 'Vagas disponíveis'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${run['date_label']} · ${run['time_label']}',
                      style: const TextStyle(fontSize: 13, color: muted),
                    ),
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: ink,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: muted, height: 1.4),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: forest, size: 25),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    style: const TextStyle(color: muted, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: forest),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: forest),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 12, color: muted)),
        ],
      ),
    );
  }
}

class _DarkStat extends StatelessWidget {
  const _DarkStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFD9E5DD), fontSize: 11),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1E9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: forest,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        minVerticalPadding: 12,
        leading: Icon(icon, color: forest, size: 26),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBD9A6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF795A12)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF594514),
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: forest,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 30, color: forest),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            body,
            style: const TextStyle(color: muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AudioCard extends StatelessWidget {
  const _AudioCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: forest, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(text, style: const TextStyle(height: 1.45)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = const Color(0xFF213B32)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final roadPaint = Paint()
      ..color = const Color(0xFF385247)
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final road = Path()
      ..moveTo(size.width * 0.08, size.height * 0.75)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.48,
        size.height * 0.95,
        size.width * 0.63,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.18,
        size.width * 0.83,
        size.height * 0.78,
        size.width * 0.94,
        size.height * 0.3,
      );
    canvas.drawPath(road, roadPaint);

    final routePaint = Paint()
      ..color = lime
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final route = Path()
      ..moveTo(size.width * 0.08, size.height * 0.75)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.2,
        size.width * 0.48,
        size.height * 0.95,
        size.width * 0.63,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.18,
        size.width * 0.83,
        size.height * 0.78,
        size.width * 0.94,
        size.height * 0.3,
      );
    canvas.drawPath(route, routePaint);

    final markerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.75),
      7,
      markerPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.94, size.height * 0.3),
      8,
      Paint()..color = lime,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
