library io_keycloak_helper;
import 'dart:convert';
import 'dart:io';
// import 'package:flutter/cupertino.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _KeyClockConstantsSubUrl {
  static var logout = "/protocol/openid-connect/logout";
  static var login = "/protocol/openid-connect/auth";
  static var token = "/protocol/openid-connect/token";
}
/// This is wrapper class for handeling keycloak login for mobile
class IOKeycloakHelper {
 IOKeycloakHelper._();

  /// Global instance of the [IOKeycloakHelper]
  static final IOKeycloakHelper instance = IOKeycloakHelper._();
  // late BuildContext context;



// late KeycloakService globalKeycloakService;
   var _authServerUrl = ""; 
   var _realm = "";
   var _clientId = "";
   var _redirectUrl = "";
   String? _clientSecret;

   /// after successful login call this method to get accessToken
   Future<String?> getAccessToken() async {
    return await _KeycloakSharedPref.getAccessToken(); 
   }
   Future<String?> getRefreshToken() async {
    return await _KeycloakSharedPref.getRefreshToken(); 
   }
   /// check if user is loggedIn or not
   Future<bool> isLoggedIn() async {
    var accessToken = await getAccessToken();
    if (accessToken != null && accessToken != "") {
      return true;
    }
    return false;
   }
   /// check if token is exired or not
   Future<bool> isAccessTokenExpired() async {
    var accessToken = await getAccessToken();
    if (accessToken != null && accessToken != "") {
       DateTime expirationDate = JwtDecoder.getExpirationDate(accessToken);
       var today = DateTime.now();
       print(expirationDate.toIso8601String());
      return expirationDate.isBefore(today);
    }
    return true;
  }
  /// check if refresh token is exired or not
   Future<bool> isRefreshTokenExpired() async {
    var refreshToken = await getRefreshToken();
    if (refreshToken != null && refreshToken != "") {
       DateTime expirationDate = JwtDecoder.getExpirationDate(refreshToken);
       var today = DateTime.now();
      //  print(expirationDate.toIso8601String());
      return expirationDate.isBefore(today);
    }
    return true;
  }

   String _getTokenUrl(){
    return '${_authServerUrl}realms/$_realm${_KeyClockConstantsSubUrl.token}';
   }
   String _getLoginAuthUrl(){
    return '${_authServerUrl}realms/$_realm${_KeyClockConstantsSubUrl.login}';
   }
   /// configure keycloak details
  void configureKeycloak({required String authServerUrl,required String realm,required String clientId, required String redirectUrl, String? clientSecret}) {
    _authServerUrl = authServerUrl;
    _realm = realm;
    _clientId = clientId;
     _redirectUrl = redirectUrl;
     _clientSecret = clientSecret;
    
  }
 /// this function will logout keycloak
  Future<bool> logout() async {
  var loggedIn = await isLoggedIn();
    if (loggedIn == true) {
   
        var accessToken = await getAccessToken();
        var refreshToken = await getRefreshToken();
        if ((accessToken != null && accessToken != "") && (refreshToken != null && refreshToken != "")) {
          await _kcLogoutAPICallMobile(accessToken , refreshToken);
        }
      
    }
    await _KeycloakSharedPref.clearAllPreferences();
    return true;
 }
  /// call this function to launch keycloak login screen, before this calling configureKeycloak() is must
  Future<String?> authenticateWithKeycloak() async {
    
      var clientId = _clientId;
      var scopes = List<String>.of(['openid', 'profile']);

      String authUrl = _getLoginAuthUrl();

      String tokenUrl = _getTokenUrl();

      FlutterAppAuth appAuth = const FlutterAppAuth();

      final AuthorizationTokenResponse? result =
          await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          _redirectUrl,
          clientSecret: _clientSecret,
          serviceConfiguration: AuthorizationServiceConfiguration(
              authorizationEndpoint: authUrl, tokenEndpoint: tokenUrl),
          scopes: scopes,
          preferEphemeralSession: true,
          allowInsecureConnections: true,
        ),
      );
      if (result != null) {
       
        await _KeycloakSharedPref.clearAllPreferences();

        await _KeycloakSharedPref.setLoggedInDetails(
            result.accessToken ?? "", result.refreshToken ?? "");
        
        return result.accessToken;
      }
      return null;
     
  }

Future<String?> reAuthenticateLoggedInUser() async {
  var isExpired = await isRefreshTokenExpired();
    if (isExpired) {
      throw Exception("Session Expired");
    }else {
      try {
      var refreshToken = await getRefreshToken();
       var result = await _kcAuthenticateUsingRefreshToken(refreshToken ?? "");
       http.Response re = result;
      Map<String, dynamic> body = jsonDecode(re.body);
       var accessTokenNew = body["access_token"];
       var refreshTokenNew = body["refresh_token"];
       if (accessTokenNew != null && refreshTokenNew != null) {
          await _KeycloakSharedPref.clearAllPreferences();

        await _KeycloakSharedPref.setLoggedInDetails(
            accessTokenNew ?? "", refreshTokenNew ?? "");
        return accessTokenNew;
       }else {
        throw Exception("Session Expired");
       }
      } on Exception {
      rethrow;
    }
    }
}

 Future<dynamic> _kcAuthenticateUsingRefreshToken(String refreshToken,) async {
    final url = "${_authServerUrl}realms/$_realm${_KeyClockConstantsSubUrl.token}";
   
    try {
      var responseJson = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          // HttpHeaders.authorizationHeader: "Bearer $accessToken",
        },
        encoding: Encoding.getByName('utf-8'),
        body: {
          "client_id": _clientId,
          "grant_type":"refresh_token",
          "refresh_token": refreshToken
        },
      );
      return responseJson;
    } on SocketException {
      rethrow;
    }
  }

  Future<dynamic> _kcLogoutAPICallMobile(
    String accessToken,
      String refreshToken,) async {
    final url = "${_authServerUrl}realms/$_realm${_KeyClockConstantsSubUrl.logout}";
   
    try {
      var responseJson = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $accessToken",
        },
        encoding: Encoding.getByName('utf-8'),
        body: {
          "client_id": _clientId,
          "refresh_token": refreshToken
        },
      );
      return responseJson;
    } on SocketException {
      rethrow;
    }
  }
}
class _KeycloakSharedPref {
  static const kcAccessToken = "io_keycloak_helper_access_token";
  static const kcRefreshToken = "io_keycloak_helper_access_token";
  static Future<bool> setLoggedInDetails(String accessToken, String refreshToken,
     ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(kcAccessToken, accessToken);
    prefs.setString(kcRefreshToken, refreshToken);
    return true;
  }
   static Future<String?> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(kcAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(kcRefreshToken);
  }
  static Future<void> clearAllPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(kcAccessToken);
    await prefs.remove(kcRefreshToken);
  }
}