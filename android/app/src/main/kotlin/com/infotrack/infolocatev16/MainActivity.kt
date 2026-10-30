package com.infotrack.infolocatev16

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity is a ComponentActivity, required by enableEdgeToEdge().
// AppBar / SafeArea keep content clear of system bars on older devices too.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        // FlutterFragmentActivity still calls deprecated setStatusBarColor in
        // configureStatusBarForFullscreenFlutterExperience(); re-assert edge-to-edge.
        enableEdgeToEdge()
    }
}
