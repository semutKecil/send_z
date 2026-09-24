import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:send_z/app_router.dart';
import 'package:send_z/core/utils/app_theme.dart';
import 'package:send_z/core/utils/url_strategy/url_strategy.dart';
import 'package:send_z/features/receive/bloc/receive_bloc.dart';
import 'package:send_z/features/send/bloc/send_bloc.dart';
import 'package:send_z/features/transfer/bloc/transfer_bloc.dart';

final GetIt getIt = GetIt.instance;
const hashRouting = true;
late final String baseUrl;
const String defaultRelay = 'wss://nos.lol';
const Map<String, dynamic> defaultRtcConfig = {
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun.cloudflare.com:3478'},
  ],
};

void main() {
  if (kIsWeb) {
    baseUrl = "${Uri.base.origin}${Uri.base.path}";
  } else {
    //default to repository page. change this with your own
    baseUrl = "https://semutKecil.github.io/send_z/";
  }
  if (!hashRouting) {
    useCleanUrlStrategy();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TransferBloc transferBloc = TransferBloc();

  @override
  void dispose() {
    transferBloc.close();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final router = AppRouter();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReceiveBloc(transferBloc: transferBloc),
        ),
        BlocProvider(create: (context) => SendBloc(transferBloc: transferBloc)),
        BlocProvider(create: (context) => transferBloc),
      ],
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: router.config(),
      ),
    );
  }
}
