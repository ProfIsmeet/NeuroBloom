import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/storage_keys.dart';
import 'core/router/app_router.dart';
import 'core/storage/hive_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/application/profile_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox<String>(StorageKeys.hiveBoxName);
  final storageService = HiveStorageService(box);

  runApp(
    ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storageService)],
      child: const NeuroBloomApp(),
    ),
  );
}

class NeuroBloomApp extends StatefulWidget {
  const NeuroBloomApp({super.key});

  @override
  State<NeuroBloomApp> createState() => _NeuroBloomAppState();
}

class _NeuroBloomAppState extends State<NeuroBloomApp> {
  late final GoRouter _router = AppRouter.createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NeuroBloom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
