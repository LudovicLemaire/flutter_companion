// import 'package:flutter/foundation.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_compagnion/get_token.dart';
import 'package:lottie/lottie.dart';
import 'strings.dart' as strings;
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() => runApp(const FlutterCompanionAppApp());

class FlutterCompanionAppApp extends StatelessWidget {
  const FlutterCompanionAppApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GlobalViewModel>(
        create: (BuildContext context) => GlobalViewModel(),
        child: SkeletonTheme(
            darkShimmerGradient: const LinearGradient(colors: [
              Color.fromARGB(255, 84, 84, 134),
              Color.fromARGB(255, 86, 86, 136),
              Color.fromARGB(255, 93, 93, 143),
              Color.fromARGB(255, 86, 86, 136),
              Color.fromARGB(255, 84, 84, 134),
            ]),
            child: MaterialApp(
              title: strings.appTitle,
              theme: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark()
                    .copyWith(primary: const Color.fromARGB(255, 97, 128, 238)),
                primaryColor: const Color(0xFF7289da),
                secondaryHeaderColor: const Color.fromARGB(255, 93, 93, 143),
              ),
              home: const GetToken(),
              builder: (context, child) {
                return Stack(
                  children: [
                    child!,
                    Provider.of<GlobalViewModel>(context).loadingOverlay
                        ? _overlayLoading()
                        : const SizedBox.shrink()
                  ],
                );
              },
            )));
  }

  Widget _overlayLoading() {
    return Stack(children: [
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.75, sigmaY: 0.75),
        child: Container(
          color: Colors.black.withOpacity(0.65),
        ),
      ),
      Center(
        child: Lottie.asset(
          kIsWeb ? '../assets/spaceLottie3.json' : 'assets/spaceLottie3.json',
          width: 200,
          height: 200,
          fit: BoxFit.fill,
        ),
      )
    ]);
  }
}

class GlobalViewModel extends ChangeNotifier {
  String _token = 'missing';
  bool _loadingOverlay = false;

  String get token => _token;
  bool get loadingOverlay => _loadingOverlay;

  void editToken(String newToken, int expireIn, BuildContext context) {
    _token = newToken;
    notifyListeners();
    if (expireIn < 250) {
      getToken(context);
    } else {
      _waitExpiresToken(context, expireIn - 150);
    }
  }

  void editLoadingOverlay(bool v) {
    _loadingOverlay = v;
    notifyListeners();
  }

  Future<void> _waitExpiresToken(BuildContext context, int expireIn) async {
    await Future.delayed(Duration(seconds: expireIn));
    getToken(context);
  }
}
