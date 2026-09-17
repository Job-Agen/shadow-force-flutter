import 'models.dart';

const _technique = <Pose, (List<String>, String)>{
  Pose.guard: (
    [
      'Place ton pied gauche devant si tu es droitier, sur deux rails imaginaires.',
      'Fléchis légèrement les genoux et garde ton poids réparti entre les deux jambes.',
      'Monte les poings près des joues, coudes proches du corps et menton baissé.',
      'Regarde devant toi et garde les épaules détendues pendant que tu respires.',
    ],
    'Ne colle pas les pieds et ne lève pas le menton.',
  ),
  Pose.jab: (
    [
      'Pars de ta garde et pousse légèrement sur le pied arrière.',
      'Envoie le poing avant tout droit vers la cible, sans faire un grand arc.',
      'Tourne légèrement le poing à la fin et expire brièvement : « tsh ».',
      'Ramène immédiatement la main à la joue avant de bouger ou refrapper.',
    ],
    'Ne verrouille pas le coude et ne laisse pas tomber la main après le coup.',
  ),
  Pose.cross: (
    [
      'Pars de la garde avec la main avant toujours près du visage.',
      'Pivote le talon arrière et tourne la hanche puis l’épaule arrière.',
      'Projette le poing arrière en ligne droite, sans te pencher vers l’avant.',
      'Ramène le poing et replace immédiatement les hanches face à l’adversaire.',
    ],
    'Ne frappe pas seulement avec le bras : la puissance vient du sol et de la hanche.',
  ),
  Pose.hook: (
    [
      'Garde le bras plié et le coude approximativement à hauteur du poing.',
      'Pivote le pied et la hanche du même côté que le crochet.',
      'Dessine un arc court ; arrête le coup devant le centre de ton visage.',
      'Garde l’autre main sur la joue et reviens immédiatement en garde.',
    ],
    'Ne fais pas un grand mouvement circulaire et ne baisse pas l’autre main.',
  ),
  Pose.slip: (
    [
      'Imagine un direct qui arrive vers le centre de ton visage.',
      'Fléchis un peu les genoux et déplace la tête de quelques centimètres.',
      'Garde les yeux sur l’adversaire et les mains près du visage.',
      'Reviens au centre ou réponds immédiatement avec un jab–cross.',
    ],
    'Ne te penche pas à la taille et ne fais pas une esquive trop large.',
  ),
  Pose.footwork: (
    [
      'Pour aller à gauche, déplace d’abord le pied gauche ; inversement à droite.',
      'Le second pied suit exactement la même distance pour retrouver ta garde.',
      'Reste sur l’avant des pieds avec les genoux souples et le regard devant.',
      'Arrête-toi équilibré avant de déclencher ta combinaison.',
    ],
    'Ne croise jamais les pieds et ne les rapproche pas complètement.',
  ),
  Pose.strength: (
    [
      'Fais 8 à 12 pompes, corps gainé ; pose les genoux si nécessaire.',
      'Enchaîne 15 squats en poussant les hanches vers l’arrière.',
      'Tiens une planche 20 à 30 secondes sans creuser le dos.',
      'Récupère 30 secondes puis recommence le circuit trois fois.',
    ],
    'Arrête le mouvement en cas de douleur vive ou articulaire.',
  ),
  Pose.breathe: (
    [
      'Relâche les poings, la mâchoire et les épaules.',
      'Inspire par le nez pendant quatre secondes.',
      'Expire lentement par la bouche pendant six secondes.',
      'Marche doucement sur place et laisse le rythme cardiaque redescendre.',
    ],
    'Ne force pas les étirements sur des muscles encore chauds.',
  ),
};

const _themes = <(String, String, Pose)>[
  ('Construire ta garde', 'Garde', Pose.guard),
  ('Un jab propre', 'Jab', Pose.jab),
  ('Ajouter le cross', 'Jab–cross', Pose.cross),
  ('Bouger sans croiser les pieds', 'Déplacements', Pose.footwork),
  ('Lier pieds et poings', 'Coordination', Pose.jab),
  ('Renforcement de base', 'Force', Pose.strength),
  ('Récupération technique', 'Mobilité', Pose.breathe),
  ('Réviser les fondations', 'Garde + 1–2', Pose.cross),
  ('Découvrir le crochet', 'Crochet', Pose.hook),
  ('Esquiver avec le slip', 'Défense', Pose.slip),
  ('Attaquer puis sortir', 'Angles', Pose.footwork),
  ('Force et stabilité', 'Force', Pose.strength),
  ('Voir l’adversaire', 'Visualisation', Pose.guard),
  ('Récupérer sans perdre le geste', 'Technique lente', Pose.breathe),
  ('Enchaîner 1–2–3', 'Combinaisons', Pose.hook),
  ('Slip puis contre-attaque', 'Défense + contre', Pose.slip),
  ('Changer le rythme', 'Tempo', Pose.cross),
  ('Renforcement complet', 'Force', Pose.strength),
  ('Décider sous pression', 'Concentration', Pose.slip),
  ('Première simulation', 'Simulation', Pose.cross),
  ('Récupération active', 'Mobilité', Pose.breathe),
  ('Précision avant vitesse', 'Précision', Pose.jab),
  ('Travail des angles', 'Déplacements', Pose.footwork),
  ('Endurance de garde', 'Endurance', Pose.guard),
  ('Force explosive contrôlée', 'Force', Pose.strength),
  ('Lecture et réaction', 'Réactivité', Pose.slip),
  ('Round libre guidé', 'Créativité', Pose.hook),
  ('Simulation longue', 'Simulation', Pose.cross),
  ('Affûtage technique', 'Technique', Pose.jab),
  ('Test final : reste propre', 'Évaluation', Pose.cross),
];

List<TrainingDay> buildProgram() => List.generate(30, (index) {
      final day = index + 1;
      final theme = _themes[index];
      final recovery = const [7, 14, 21].contains(day);
      final phase = day <= 7
          ? 'Fondations'
          : day <= 14
              ? 'Coordination'
              : day <= 21
                  ? 'Réactivité'
                  : 'Maîtrise';
      final duration = recovery ? 15 : 15 + (index ~/ 6) * 3;
      final seconds = recovery ? 300 : day <= 7 ? 360 : day <= 21 ? 480 : 600;
      final info = _technique[theme.$3]!;
      return TrainingDay(
        day: day,
        title: theme.$1,
        focus: theme.$2,
        phase: phase,
        duration: duration.clamp(15, 30),
        recovery: recovery,
        steps: [
          ExerciseStep(
            title: 'Mise en route',
            subtitle: 'Mobilité, garde et petits pas',
            seconds: 120,
            pose: Pose.guard,
            instructions: _technique[Pose.guard]!.$1,
            mistake: _technique[Pose.guard]!.$2,
          ),
          ExerciseStep(
            title: theme.$2,
            subtitle: recovery ? 'Mouvement lent et respiration calme' : 'Technique avant vitesse',
            seconds: seconds,
            pose: theme.$3,
            instructions: info.$1,
            mistake: info.$2,
          ),
          ExerciseStep(
            title: theme.$3 == Pose.strength ? 'Bloc force' : 'Focus mental',
            subtitle: theme.$3 == Pose.strength ? 'Pompes · squats · gainage' : 'Visualise, décide et réagis',
            seconds: duration * 60 - seconds - 240,
            pose: theme.$3 == Pose.strength ? Pose.strength : Pose.slip,
            instructions: _technique[theme.$3 == Pose.strength ? Pose.strength : Pose.slip]!.$1,
            mistake: _technique[theme.$3 == Pose.strength ? Pose.strength : Pose.slip]!.$2,
          ),
          ExerciseStep(
            title: 'Retour au calme',
            subtitle: 'Respiration et relâchement',
            seconds: 120,
            pose: Pose.breathe,
            instructions: _technique[Pose.breathe]!.$1,
            mistake: _technique[Pose.breathe]!.$2,
          ),
        ],
      );
    });
