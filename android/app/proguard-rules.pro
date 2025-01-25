# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }

# File Picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Video Player
-keep class com.google.android.exoplayer.** { *; }

# RCS Demo App
-keep class com.example.rcs_demo_app.** { *; }

# Keep models
-keep class com.example.rcs_demo_app.models.** { *; }