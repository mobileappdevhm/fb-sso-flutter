class AccessToken {
  /**
   * The underlying access token.
   */
  final String accessToken;

  /**
   * Type of the token.
   */
  final String tokenType;

  /**
   * Seconds until expiration.
   */
  final num expiresIn;

  AccessToken(this.accessToken, this.tokenType, this.expiresIn);

  AccessToken.fromMap(Map<String, dynamic> json)
      : accessToken = json["access_token"],
        tokenType = json["token_type"],
        expiresIn = json["expires_in"];
}
