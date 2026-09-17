# Shadow Force — Flutter

Application mobile de shadow boxing sans matériel, avec programme progressif de
30 jours, séances guidées, démonstrations animées, chronomètre et sauvegarde de
la progression sur l'appareil.

## Lancer le projet

1. Installer Flutter stable et Android Studio.
2. Dans ce dossier, générer les plateformes si nécessaire :
   `flutter create --platforms=android,ios .`
3. Installer les dépendances : `flutter pub get`
4. Vérifier : `flutter analyze && flutter test`
5. Lancer : `flutter run`

## Construire l'APK

`flutter build apk --release`

L'APK sera créé dans `build/app/outputs/flutter-apk/app-release.apk`.
