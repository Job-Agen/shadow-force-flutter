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
  void initState() { super.initState(); store.load(); }
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Shadow Force',
    theme: buildTheme(),
    home: AnimatedBuilder(animation: store, builder: (_, __) => AppShell(store: store)),
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
    final day = buildProgram()[widget.store.nextDay - 1];
    final pages = [
      HomeScreen(store: widget.store),
      ProgramScreen(store: widget.store),
      TrainingOverview(day: day, store: widget.store),
      ProgressScreen(store: widget.store),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: AppColors.lime), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.view_list_outlined), selectedIcon: Icon(Icons.view_list, color: AppColors.lime), label: 'Programme'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle, color: AppColors.lime), label: 'Entraînement'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart, color: AppColors.lime), label: 'Progression'),
        ],
      ),
    );
  }
}

void openWorkout(BuildContext context, TrainingDay day, ProgressStore store) =>
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkoutScreen(day: day, store: store)));

class BrandLockup extends StatelessWidget {
  const BrandLockup({super.key});
  @override
  Widget build(BuildContext context) => Row(children: const [
    Icon(Icons.bolt, color: AppColors.lime, size: 42),
    SizedBox(width: 4),
    Text('SHADOW FORCE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: -.7)),
  ]);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});
  final ProgressStore store;
  @override
  Widget build(BuildContext context) {
    final day = buildProgram()[store.nextDay - 1];
    return Stack(children: [
      Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.ink, const Color(0xFF07192A), AppColors.ink])))),
      ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 24), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Accueil', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), Icon(Icons.settings_outlined)]),
        const SizedBox(height: 18),
        const BrandLockup(),
        const Padding(padding: EdgeInsets.only(left: 49), child: Text('DISCIPLINE AUJOURD’HUI\nUN MEILLEUR TOI DEMAIN', style: TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 2.4, height: 1.5))),
        const SizedBox(height: 12),
        Stack(children: [
          BoxerIllustration(pose: day.steps[1].pose, height: 390, fit: BoxFit.cover, alignment: Alignment.topCenter),
          Positioned(left: 0, top: 24, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('TON\nENTRAÎNEMENT', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 15),
            Container(width: 190, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: .88), border: Border.all(color: AppColors.blue.withValues(alpha: .35)), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Jour ${day.day}', style: const TextStyle(color: AppColors.lime, fontSize: 19, fontWeight: FontWeight.w900)),
              Text(day.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(children: [const Icon(Icons.schedule, size: 19, color: AppColors.muted), const SizedBox(width: 7), Text('${day.duration} min')]),
            ])),
          ])),
          const Positioned(left: 0, bottom: 20, child: Text('PLUS FORT\nPLUS DISCIPLINÉ\nJOUR APRÈS JOUR', style: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.8, letterSpacing: 1.4))),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Progression du programme', style: TextStyle(color: AppColors.muted)), Text('${store.completedCount}/30', style: const TextStyle(fontWeight: FontWeight.w900))]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(5), child: LinearProgressIndicator(value: store.completedCount / 30, minHeight: 8, backgroundColor: AppColors.surface2)),
        const SizedBox(height: 18),
        FilledButton.icon(onPressed: () => openWorkout(context, day, store), icon: const Icon(Icons.play_arrow), label: const Text('DÉMARRER LA SÉANCE')),
      ]),
    ]);
  }
}

class ProgramScreen extends StatelessWidget {
  const ProgramScreen({super.key, required this.store});
  final ProgressStore store;
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
    const SliverAppBar(floating: true, title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Programme', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), Text('30 jours · 4 phases', style: TextStyle(fontSize: 13))])),
    SliverPadding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), sliver: SliverList.builder(itemCount: 30, itemBuilder: (context, index) {
      final day = buildProgram()[index]; final done = store.completedDays.contains(day.day); final unlocked = day.day <= store.nextDay;
      final newPhase = day.day == 1 || day.day == 8 || day.day == 15 || day.day == 22;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (newPhase) Padding(padding: const EdgeInsets.fromLTRB(4, 16, 4, 8), child: Row(children: [Container(width: 9, height: 9, decoration: const BoxDecoration(color: AppColors.lime, shape: BoxShape.circle)), const SizedBox(width: 8), Text('PHASE ${day.day == 1 ? 1 : day.day == 8 ? 2 : day.day == 15 ? 3 : 4}  ·  ${day.phase.toUpperCase()}', style: const TextStyle(color: AppColors.lime, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .8))])),
        Padding(padding: const EdgeInsets.only(bottom: 9), child: Card(shape: RoundedRectangleBorder(side: BorderSide(color: day.day == store.nextDay ? AppColors.lime : Colors.white.withValues(alpha: .08), width: day.day == store.nextDay ? 1.5 : 1), borderRadius: BorderRadius.circular(14)), child: InkWell(onTap: unlocked ? () => openWorkout(context, day, store) : null, borderRadius: BorderRadius.circular(14), child: SizedBox(height: 82, child: Row(children: [
          SizedBox(width: 104, child: ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)), child: Image.asset(day.steps[1].pose == Pose.cross || day.steps[1].pose == Pose.jab || day.steps[1].pose == Pose.hook ? 'assets/images/athlete_cross.jpg' : 'assets/images/athlete_guard.jpg', fit: BoxFit.cover, alignment: Alignment.topCenter))),
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Jour ${day.day}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), Text(day.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: unlocked ? Colors.white : AppColors.muted)), const Spacer(), Row(children: [const Icon(Icons.schedule, size: 15, color: AppColors.muted), const SizedBox(width: 5), Text('${day.duration} min', style: const TextStyle(color: AppColors.muted, fontSize: 11))])]))),
          Padding(padding: const EdgeInsets.only(right: 12), child: Icon(done ? Icons.check_circle : unlocked ? Icons.circle_outlined : Icons.lock, color: done ? AppColors.lime : AppColors.muted)),
        ]))))),
      ]);
    })),
  ]);
}

class TrainingOverview extends StatelessWidget {
  const TrainingOverview({super.key, required this.day, required this.store});
  final TrainingDay day; final ProgressStore store;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Entraînement', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
    const SizedBox(height: 16),
    const Text('ÉTAPE 2 / 4', textAlign: TextAlign.center, style: TextStyle(color: AppColors.blue, letterSpacing: 1.5, fontWeight: FontWeight.w800)),
    Text(day.focus, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
    BoxerIllustration(pose: day.steps[1].pose, height: 380, fit: BoxFit.cover),
    FilledButton.icon(onPressed: () => openWorkout(context, day, store), icon: const Icon(Icons.play_arrow), label: const Text('DÉMARRER')),
    const SizedBox(height: 14),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 12), ...day.steps[1].instructions.indexed.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [CircleAvatar(radius: 12, backgroundColor: AppColors.blue, child: Text('${item.$1 + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900))), const SizedBox(width: 10), Expanded(child: Text(item.$2, maxLines: 2, overflow: TextOverflow.ellipsis))])))]))),
  ]);
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.store}); final ProgressStore store;
  @override
  Widget build(BuildContext context) {
    final count = store.completedCount;
    final minutes = buildProgram().where((d) => store.completedDays.contains(d.day)).fold<int>(0, (sum, d) => sum + d.duration);
    return ListView(padding: const EdgeInsets.all(18), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Progression', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), Row(children: [Icon(Icons.bolt, color: AppColors.lime, size: 34), Text('MÊME AUJOURD’HUI\nTU AVANCES', style: TextStyle(color: AppColors.muted, fontSize: 9, height: 1.4))])]),
      const SizedBox(height: 18),
      Row(children: ['Vue d’ensemble', 'Phases', 'Compétences'].indexed.map((e) => Expanded(child: Container(margin: EdgeInsets.only(right: e.$1 < 2 ? 7 : 0), padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: e.$1 == 0 ? AppColors.lime : AppColors.surface, borderRadius: BorderRadius.circular(11)), child: Text(e.$2, textAlign: TextAlign.center, style: TextStyle(color: e.$1 == 0 ? AppColors.ink : Colors.white, fontSize: 11, fontWeight: FontWeight.w800))))).toList()),
      const SizedBox(height: 24),
      Center(child: SizedBox(width: 190, height: 190, child: Stack(alignment: Alignment.center, children: [SizedBox.expand(child: CircularProgressIndicator(value: count / 30, strokeWidth: 15, backgroundColor: AppColors.surface2, strokeCap: StrokeCap.round)), Column(mainAxisSize: MainAxisSize.min, children: [Text('$count/30', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)), const Text('Jours complétés', style: TextStyle(color: AppColors.muted))])]))),
      const SizedBox(height: 22),
      Row(children: [Expanded(child: _Stat(icon: Icons.local_fire_department, value: '$count', label: 'jours de suite')), const SizedBox(width: 10), Expanded(child: _Stat(icon: Icons.schedule, value: '$minutes', label: 'minutes actives'))]),
      const SizedBox(height: 14),
      Container(height: 98, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)), child: Row(children: [const Expanded(child: Text('« LA DISCIPLINE\nTRANSFORME LES EFFORTS\nEN RÉSULTATS. »', style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.6, letterSpacing: .8))), SizedBox(width: 95, child: Image.asset('assets/images/athlete_guard.jpg', fit: BoxFit.cover, alignment: Alignment.topCenter))])),
      const SizedBox(height: 18),
      const Text('Tes jalons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      ...[(7, 'Les bases acquises'), (14, 'Plus de fluidité'), (21, 'Une vraie puissance'), (30, 'Tu as relevé le défi !')].map((m) => Card(child: ListTile(leading: const Icon(Icons.emoji_events, color: AppColors.muted), title: Text('Jour ${m.$1}', style: const TextStyle(fontWeight: FontWeight.w900)), subtitle: Text(m.$2), trailing: Icon(count >= m.$1 ? Icons.check_circle : Icons.lock, color: count >= m.$1 ? AppColors.lime : AppColors.muted)))),
    ]);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label}); final IconData icon; final String value; final String label;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(icon, color: AppColors.blue, size: 29), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10))])])) ;
}
