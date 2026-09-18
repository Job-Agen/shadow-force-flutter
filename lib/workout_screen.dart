import 'dart:async';
import 'package:flutter/material.dart';
import 'boxer_illustration.dart';
import 'models.dart';
import 'progress_store.dart';
import 'theme.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key, required this.day, required this.store});
  final TrainingDay day;
  final ProgressStore store;
  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with WidgetsBindingObserver {
  int stepIndex = 0;
  int secondsLeft = 0;
  bool running = false;
  Timer? timer;

  ExerciseStep get step => widget.day.steps[stepIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    secondsLeft = step.seconds;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _pause();
  }

  void _toggle() => running ? _pause() : _start();
  void _start() {
    setState(() => running = true);
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (secondsLeft <= 1) {
        _next(auto: true);
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  void _pause() {
    timer?.cancel();
    if (mounted) setState(() => running = false);
  }

  void _next({bool auto = false}) {
    timer?.cancel();
    if (stepIndex == widget.day.steps.length - 1) {
      _finish();
      return;
    }
    setState(() {
      stepIndex++;
      secondsLeft = step.seconds;
      running = false;
    });
    if (auto) _start();
  }

  Future<void> _finish() async {
    _pause();
    await widget.store.complete(widget.day.day);
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 34),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircleAvatar(radius: 36, backgroundColor: AppColors.lime, child: Icon(Icons.check, color: AppColors.ink, size: 38)),
          const SizedBox(height: 18),
          const Text('Séance terminée !', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Jour ${widget.day.day} validé. Technique propre, progression réelle.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 24),
          FilledButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('REVENIR À L’ACCUEIL')),
        ]),
      ),
    );
  }

  String get formatted {
    final minutes = secondsLeft ~/ 60;
    final seconds = secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(icon: const Icon(Icons.close), onPressed: () { _pause(); Navigator.pop(context); }),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Jour ${widget.day.day} · ${widget.day.title}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        Text('Étape ${stepIndex + 1}/${widget.day.steps.length}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      ]),
      actions: [IconButton(onPressed: _showTechnique, icon: const Icon(Icons.more_vert))],
    ),
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: (stepIndex + 1) / widget.day.steps.length, minHeight: 6, backgroundColor: AppColors.surface2),
        ),
        const SizedBox(height: 18),
        Align(alignment: Alignment.centerLeft, child: Text('ÉTAPE ${stepIndex + 1} / ${widget.day.steps.length}', style: const TextStyle(color: AppColors.lime, fontWeight: FontWeight.w900, letterSpacing: 1.3))),
        const SizedBox(height: 5),
        Align(alignment: Alignment.centerLeft, child: Text(step.title, style: const TextStyle(fontSize: 35, fontWeight: FontWeight.w900))),
        Align(alignment: Alignment.centerLeft, child: Text(step.subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 15))),
        Expanded(child: BoxerIllustration(
          key: ValueKey('${step.pose}-$stepIndex'),
          pose: step.pose,
          height: 350,
          fit: BoxFit.cover,
          playing: running,
        )),
        Text(formatted, style: const TextStyle(fontSize: 58, fontWeight: FontWeight.w900, fontFeatures: [FontFeature.tabularFigures()])),
        const SizedBox(height: 4),
        Text(running ? 'GARDE LE CONTRÔLE' : 'PRÊT ?', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: _toggle, icon: Icon(running ? Icons.pause : Icons.play_arrow), label: Text(running ? 'PAUSE' : 'DÉMARRER'), style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(58), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))))),
          const SizedBox(width: 12),
          Expanded(child: FilledButton.icon(onPressed: () => _next(), icon: const Icon(Icons.arrow_forward), label: const Text('SUIVANT'))),
        ]),
        const SizedBox(height: 10),
        TextButton.icon(onPressed: _showTechnique, icon: const Icon(Icons.menu_book_outlined), label: const Text('COMMENT FAIRE')),
      ]),
    )),
  );

  void _showTechnique() {
    _pause();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TechniqueScreen(step: step)));
  }
}

class TechniqueScreen extends StatelessWidget {
  const TechniqueScreen({super.key, required this.step});
  final ExerciseStep step;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const BackButton()),
    body: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 32), children: [
      const Text('Comment faire', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
      Text('${step.title} puissant et propre, étape par étape.', style: const TextStyle(color: AppColors.muted, fontSize: 15)),
      const SizedBox(height: 18),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 4, child: BoxerIllustration(pose: step.pose, height: 430, fit: BoxFit.cover, alignment: Alignment.topCenter)),
        const SizedBox(width: 10),
        Expanded(flex: 6, child: Column(children: step.instructions.indexed.map((entry) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(13), border: Border.all(color: AppColors.blue.withValues(alpha: .2))),
          child: Row(children: [
            CircleAvatar(radius: 18, backgroundColor: AppColors.blue, child: Text('${entry.$1 + 1}', style: const TextStyle(fontWeight: FontWeight.w900))),
            const SizedBox(width: 10),
            Expanded(child: Text(entry.$2, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.25))),
          ]),
        )).toList())),
      ]),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: .10), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.danger.withValues(alpha: .35))), child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 36), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('À éviter', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w900)), Text(step.mistake, style: const TextStyle(color: Color(0xFFFFB2B2), height: 1.35))])),
      ])),
      const SizedBox(height: 22),
      const Text('PETITS DÉTAILS. GRANDS PROGRÈS.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, letterSpacing: 2.2, fontSize: 11)),
    ]),
  );
}
