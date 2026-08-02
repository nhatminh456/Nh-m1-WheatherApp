import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'firebase_options.dart';
import 'routing/app_router.dart';
import 'shared/models/user_settings.dart';
import 'shared/repositories/settings_repository.dart';
import 'shared/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await initializeDateFormatting('vi');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final notificationService = NotificationService();
  await notificationService.initialize();
  final notificationsGranted = await notificationService.requestPermission();
  if (notificationsGranted) {
    await notificationService.scheduleDaily(
      id: 0,
      title: 'Weather update',
      body: "Check today's weather before you head out.",
      hour: 7,
      minute: 0,
    );
  }

  final settingsViewModel = SettingsViewModel(SettingsRepository());
  // Wait for settings to load before running the app
  await settingsViewModel.loadSettings();

  setupRouter(settingsViewModel);

  runApp(MyApp(settingsViewModel: settingsViewModel));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.settingsViewModel});

  final SettingsViewModel settingsViewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsViewModel,
      builder: (context, _) {
        final themeMode = switch (settingsViewModel.settings.appTheme) {
          AppTheme.system => ThemeMode.system,
          AppTheme.light => ThemeMode.light,
          AppTheme.dark => ThemeMode.dark,
        };

        return MaterialApp.router(
          title: 'Weather App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent, brightness: Brightness.light),
            textTheme: GoogleFonts.montserratTextTheme(),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent, brightness: Brightness.dark),
            textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
          ),
          themeMode: themeMode,
          locale: Locale(settingsViewModel.settings.languageCode),
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
