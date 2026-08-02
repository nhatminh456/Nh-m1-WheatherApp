import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:weatherapp/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'routing/app_router.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/unit_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await initializeDateFormatting('vi');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await UnitSettings.instance.initialize();

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UnitSettings.instance,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
            textTheme: GoogleFonts.montserratTextTheme(),
          ),
          routerConfig: appRouter,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('vi'),
            Locale('en'),
          ],
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
