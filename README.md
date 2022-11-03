
This Package will help to authenticate with keycloak for android and ios
## To install this as package in flutter project
```
 io_keycloak_helper: 
    git:
      url: https://github.com/bhima-iauro/io_keycloak_helper.git
      ref: io_keycloak_helper0.0.1
  ```
## Features And Usage
Call configureKeycloak() to configure keycloak options, this require to intiate keycloak helper, without configuring this helper will not work

 call authenticateWithKeycloak() function to show keycloak login screen and this will return access token after successful login

 call logout() function to logout from keycloak

 call isLoggedIn() to check if user logged in or not
 
 call isAccessTokenExpired() to check if token is expired or not
 
 call reAuthenticateLoggedInUser()

## Attention

Please note that your redirect url should below only to successfully launch application after login (replace com.example with your package name)

com.example:/oauth2redirect

## Steps to setup keycloak login for android

Step 1: 
  Add manifestPlaceholders as below in deafultConfig of android/app/build.gradle, replace com.example with your package name
Step 2: 
Add internet permission
<uses-permission android:name="android.permission.INTERNET"/>
Step 3:
Add usesCleartextTraffic as true in application tag in android manifest.xml as below
```
<application …android:usesCleartextTraffic="true"> 
```


## Steps to setup keycloak login for iOS

Add below json in info.plist replace com.example with your package name

```
<key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>:/oauth2redirect</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.example</string>
            </array>
        </dict>
    </array>
    
```


