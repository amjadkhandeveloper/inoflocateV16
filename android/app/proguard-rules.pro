# Flutter — keep embedding/plugins intact so release minify cannot break the engine.
# Play's ~48% rates are largely from Flutter/plugin keep rules; do not loosen further.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Google Play Core (Flutter deferred components / embedding)
-dontwarn com.google.android.play.core.**

# Firebase / Gson / OkHttp commonly pulled by plugins
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.*
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn retrofit2.**

# Google Maps
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
