import 'package:flutter/material.dart';
import 'boxer_illustration.dart';
import 'models.dart';
import 'program_data.dart';
import 'progress_store.dart';
import 'theme.dart';
import 'workout_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShadowForceApp());
}

class ShadowForceApp extends StatefulWidget {
  const ShadowForceApp({super.key});
  @override
  State<ShadowForceApp> createState() => _ShadowForceAppState();
}

class _ShadowForceAppState extends State<ShadowForceApp> {
  final store = ProgressStore();
  @override
  void initState() {
    super.initState();
    store.load();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shadow Force',
        theme: buildTheme(),
        home: AnimatedBuilder(
          animation: store,
          builder: (_, __) => AppShell(store: store),
        ),
      );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.store});
  final ProgressStore store;
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(store: widget.store),
      ProgramScreen(store: widget.store),
      ProgressScreen(store: widget.store),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Programme'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progression'),
        ],
      ),
    );
  }
}

void openWorkout(BuildContext context, TrainingDay day, ProgressStore store) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => WorkoutScreen(day: day, store: store),
  ));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});
  final ProgressStore store;
  @override
  Widget build(BuildContext context) {
    final day = buildProgram()[store.nextDay - 1];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle),
            child: const Icon(Icons.sports_mma, color: AppColors.ink),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SHADOW FORCE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4, fontSize: 19)),
            Text('Force · technique · concentration', style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ])),
          const Icon(Icons.notifications_none),
        ]),
        const SizedBox(height: 28),
        const Text('TA SÉANCE DU JOUR', style: TextStyle(color: AppColors.lime, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        Text('Jour ${day.day} · ${day.title}', style: const TextStyle(fontSize: 28, height: 1.1, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text('${day.duration} min  •  ${day.focus}  •  Sans matériel', style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              BoxerIllustration(pose: day.steps[1].pose, height: 255),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _Metric(icon: Icons.timer_outlined, value: '${day.duration} min', label: 'Durée')),
                const SizedBox(width: 10),
                Expanded(child: _Metric(icon: Icons.bolt, value: day.phase, label: 'Phase')),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () => openWorkout(context, day, store),
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(store.completedDays.contains(day.day) ? 'REFAIRE LA SÉANCE' : 'COMMENCER LA SÉANCE'),
        ),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Progression', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text('${store.completedCount}/30 jours', style: const TextStyle(color: AppColors.lime, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(value: store.completedCount / 30, minHeight: 10, backgroundColor: AppColors.surface2),
        ),
      ],
    );
  }
}

class ProgramScreen extends StatelessWidget {
  const ProgramScreen({super.key, required this.store});
  final ProgressStore store;
  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Programme 30 jours', style: TextStyle(fontWeight: FontWeight.w900)),
              Text('15 à 30 minutes chaque matin', style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ]),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            sliver: SliverList.builder(
              itemCount: buildProgram().length,
              itemBuilder: (context, index) {
                final day = buildProgram()[index];
                final done = store.completedDays.contains(day.day);
                final unlocked = day.day <= store.nextDay;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: unlocked ? () => openWorkout(context, day, store) : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: done ? AppColors.lime : AppColors.surface2,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.center,
                            child: done
                                ? const Icon(Icons.check, color: AppColors.ink)
                                : unlocked
                                    ? Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17))
                                    : const Icon(Icons.lock_outline, color: AppColors.muted, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(day.phase.toUpperCase(), style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1)),
                            const SizedBox(height: 3),
                            Text(day.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: unlocked ? Colors.white : AppColors.muted)),
                            const SizedBox(height: 4),
                            Text('${day.duration} min · ${day.focus}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          ])),
                          if (unlocked) const Icon(Icons.chevron_right),
                        ]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.store});
  final ProgressStore store;
  @override
  Widget build(BuildContext context) {
    final count = store.completedCount;
    final minutes = buildProgram().where((d) => store.completedDays.contains(d.day)).fold<int>(0, (sum, d) => sum + d.duration);
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Ta progression', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      const Text('Chaque séance propre te rapproche de la maîtrise.', style: TextStyle(color: AppColors.muted)),
      const SizedBox(height: 26),
      Center(child: SizedBox(
        width: 190, height: 190,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox.expand(child: CircularProgressIndicator(value: count / 30, strokeWidth: 16, backgroundColor: AppColors.surface2, strokeCap: StrokeCap.round)),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$count', style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900)),
            const Text('SUR 30 JOURS', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
          ]),
        ]),
      )),
      const SizedBox(height: 30),
      Row(children: [
        Expanded(child: _Metric(icon: Icons.local_fire_department_outlined, value: '$count', label: 'Séances')),
        const SizedBox(width: 12),
        Expanded(child: _Metric(icon: Icons.timer_outlined, value: '$minutes', label: 'Minutes')),
      ]),
      const SizedBox(height: 20),
      const Text('Étapes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      ...[(7, 'Fondations'), (14, 'Coordination'), (21, 'Réactivité'), (30, 'Maîtrise')].map((m) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: count >= m.$1 ? AppColors.lime : AppColors.surface2,
          foregroundColor: count >= m.$1 ? AppColors.ink : AppColors.muted,
          child: Icon(count >= m.$1 ? Icons.check : Icons.flag_outlined),
        ),
        title: Text(m.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('Objectif : ${m.$1} jours'),
      )),
      const SizedBox(height: 18),
      TextButton(onPressed: () => _confirmReset(context), child: const Text('Réinitialiser ma progression')),
    ]);
  }

  void _confirmReset(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Recommencer à zéro ?'),
      content: const Text('Toutes les séances terminées seront effacées de cet appareil.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        TextButton(onPressed: () { store.reset(); Navigator.pop(context); }, child: const Text('Réinitialiser')),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(18)),
    child: Row(children: [
      Icon(icon, color: AppColors.lime), const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      ])),
    ]),
  );
}
