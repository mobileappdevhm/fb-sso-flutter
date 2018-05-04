import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:sso/sso/access_token.dart';
import 'package:sso/sso/sso.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:flutter/services.dart' show rootBundle;

/**
 * Single-Sign-On with Facebook.
 */
class FacebookSSO extends SSO {
  static const String FACEBOOK_API_VERSION = "v2.12";

  /**
   * Facebook Application ID.
   */
  final String _applicationID;

  /**
   * Facebook Application Secret.
   */
  final String _applicationSecret;

  FacebookSSO({@required String applicationID, @required String applicationSecret})
      : this._applicationID = applicationID,
        this._applicationSecret = applicationSecret;

  @override
  Future<AccessToken> accessToken(String authorizationCode) async {
    http.Response response = await http.get("https://graph.facebook.com/$FACEBOOK_API_VERSION/oauth/access_token?"
        "client_id=$_applicationID"
        "&redirect_uri=https://localhost:8443/"
        "&client_secret=$_applicationSecret"
        "&code=$authorizationCode");

    return new AccessToken.fromMap(json.decode(response.body));
  }

  @override
  Future<String> authorize() async {
    // First and foremost start the callback server!
    Stream<String> tokenStream = await _startCallbackServer();

    // Call the facebook authorization page.
    String url = "https://www.facebook.com/$FACEBOOK_API_VERSION/dialog/oauth?"
        "client_id=$_applicationID"
        "&response_type=code"
        "&redirect_uri=https://localhost:8443/";

    UrlLauncher.launch(url);

    // Wait for the token to become available.
    return await tokenStream.first;
  }

  /**
   * Start a callback server to fetch the authorization token.
   */
  Future<Stream<String>> _startCallbackServer() async {
    StreamController<String> tokenStream = new StreamController();

    // Create new server to listen at https://localhost:8443
    SecurityContext context = await _getSecurityContext();
    HttpServer server = await HttpServer.bindSecure(InternetAddress.LOOPBACK_IP_V4, 8443, context);

    // Listen for requests
    server.listen((HttpRequest request) async {
      // Get authorization token from callback request
      String authorizationToken = request.uri.queryParameters["code"];

      // Send code to stream and close it.
      tokenStream.add(authorizationToken);
      tokenStream.close();

      // Send little response
      request.response
        ..statusCode = 200
        ..headers.set("Content-Type", ContentType.HTML.mimeType)
        ..write('''
          <!DOCTYPE html>
          <html>
            <head>
              <title>Application Login Callback</title>
              <style>*{font-family: sans-serif}</style>
            </head>
            <body>
              <h1>Callback</h1>
              <p>
                You have granted access to your profile, close this tab and return to the app.
              </p>
            </body>
          </html>
          ''');

      // Close the connection and server.
      await request.response.close();
      await server.close(force: true);
    });

    return tokenStream.stream;
  }

  /**
   * Get security context for a secure HTTPS Server.
   */
  Future<SecurityContext> _getSecurityContext() async {
    SecurityContext context = new SecurityContext();

    String cert = await rootBundle.loadString("res/cert.pem");
    String key = await rootBundle.loadString("res/key.pem");

    cert = cert.replaceAll("\r", "");
    key = key.replaceAll("\r", "");

    context.useCertificateChainBytes(utf8.encode(cert));
    context.usePrivateKeyBytes(utf8.encode(key));

    return context;
  }

}
