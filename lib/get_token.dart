import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'flutter_companion_app.dart';
import 'main.dart';
import 'creditentials.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'strings.dart' as strings;

const perPage = 10;

class GetToken extends StatefulWidget {
  const GetToken({Key? key}) : super(key: key);

  @override
  _GetToken createState() => _GetToken();
}

class _GetToken extends State<GetToken> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      Provider.of<GlobalViewModel>(context, listen: false)
          .editLoadingOverlay(true);
      _setGotToken(await getToken(context));
    });
  }

  bool _gotToken = false;
  void _setGotToken(bool v) {
    setState(() {
      _gotToken = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _gotToken
          ? const FlutterCompanionApp()
          : Scaffold(
              appBar: AppBar(
                title: const Text(strings.appTitle),
                backgroundColor: const Color(0xFF7289da),
              ),
              body: const SizedBox.shrink(),
            ),
    ]);
  }
}

Future<bool> getToken(BuildContext context) async {
  final responseToken =
      await http.post(Uri.parse('https://api.intra.42.fr/oauth/token'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'grant_type': 'client_credentials',
            'client_id': CLIENT_UID,
            'client_secret': CLIENT_SECRET,
          }));

  if (responseToken.statusCode != 200) {
    return false;
  } else {
    Provider.of<GlobalViewModel>(context, listen: false).editToken(
        jsonDecode(responseToken.body)['access_token'],
        jsonDecode(responseToken.body)['expires_in'],
        context);

    // await Future.delayed(const Duration(seconds: 3));

    return true;
  }
}
