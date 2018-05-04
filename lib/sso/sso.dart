import 'dart:async';

import 'package:sso/sso/access_token.dart';

abstract class SSO {

  /**
   * Request authorization.
   */
  Future<String> authorize();

  /**
   * Exchange the authorization code by a access token.
   */
  Future<AccessToken> accessToken(String authorizationCode);

}