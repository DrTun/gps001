1. Rename
https://pub.dev/packages/rename
flutter pub global activate rename
rename setAppName --targets ios,android --value com.nirvasoft.gps001

android.app.src.main.kotlin > com.nirvasoft.x
android.app.build.gradle com.nirvasoft.x (2 places, main activty 1)

2)
https://pub.dev/packages/location
dependencies:
  location: ^5.0.0
  Android
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
  iOS
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>Reason why we need access to your location</string>


  import 'package:location/location.dart';


  flutter pub add flutter_map latlong2