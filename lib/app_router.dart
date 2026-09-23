import 'package:auto_route/auto_route.dart';
import 'package:send_z/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: "/", page: HomeRoute.page, initial: true),
    AutoRoute(path: "/:code", page: ReceiveRoute.page),
    // AutoRoute(path: "/sent", page: SendRoute.page),
    // AutoRoute(
    //   path: "/",
    //   page: LayoutRoute.page,
    //   children: [
    //     AutoRoute(path: "accounts", page: AccountListRoute.page, initial: true),
    //     AutoRoute(path: "accounts/generate", page: AccountGenerateRoute.page),
    //     AutoRoute(path: "accounts/import", page: AccountImportRoute.page),
    //     AutoRoute(
    //       path: "accounts/import_nsec",
    //       page: AccountImportNsecRoute.page,
    //     ),
    //     AutoRoute(
    //       path: "accounts/import_mnemonic",
    //       page: AccountImportMnemonicRoute.page,
    //     ),
    //     AutoRoute(path: "accounts/restore", page: AccountRestoreRoute.page),
    //   ],
    // ),
  ];
}
