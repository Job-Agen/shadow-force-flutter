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
      actions: [IconButton(onPressed: _showTechnique, icon: const Icon(Icons.info_outline))],
    ),
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: (stepIndex + 1) / widget.day.steps.length, minHeight: 6, backgroundColor: AppColors.surface2),
        ),
        const SizedBox(height: 18),
        Text(step.title.toUpperCase(), style: const TextStyle(color: AppColors.lime, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
        const SizedBox(height: 4),
        Text(step.subtitle, style: const TextStyle(color: AppColors.muted)),
        Expanded(child: BoxerIllustration(pose: step.pose, height: 330)),
        Text(formatted, style: const TextStyle(fontSize: 58, fontWeight: FontWeight.w900, fontFeatures: [FontFeature.tabularFigures()])),
        const SizedBox(height: 4),
        Text(running ? 'GARDE LE CONTRÔLE' : 'PRÊT ?', style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: _showTechnique,
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('COMMENT FAIRE'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))),
          )),
          const SizedBox(width: 12),
          SizedBox(width: 62, height: 54, child: FilledButton(onPressed: () => _next(), style: FilledButton.styleFrom(padding: EdgeInsets.zero), child: const Icon(Icons.skip_next))),
        ]),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _toggle, icon: Icon(running ? Icons.pause : Icons.play_arrow), label: Text(running ? 'PAUSE' : 'DÉMARRER')),
      ]),
    )),
  );

  void _showTechnique() {
    _pause();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: .68,
        minChildSize: .45,
        maxChildSize: .9,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 30),
          children: [
            Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(5)))),
            const SizedBox(height: 22),
            Text('Comment faire : ${step.title}', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            ...step.instructions.indexed.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CircleAvatar(radius: 15, backgroundColor: AppColors.lime, foregroundColor: AppColors.ink, child: Text('${entry.$1 + 1}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12))),
                const SizedBox(width: 12),
                Expanded(child: Text(entry.$2, style: const TextStyle(fontSize: 15, height: 1.45))),
              ]),
            )),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: .12), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.danger.withValues(alpha: .35))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                const SizedBox(width: 10),
                Expanded(child: Text(step.mistake, style: const TextStyle(color: Color(0xFFFFB2B2), height: 1.4))),
              ]),
            ),
            const SizedBox(height: 22),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('J’AI COMPRIS')),
          ],
        ),
      ),
    );
  }
}
