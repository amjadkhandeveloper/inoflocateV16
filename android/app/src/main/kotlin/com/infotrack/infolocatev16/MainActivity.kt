package com.infotrack.infolocatev16

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity is a ComponentActivity, required by enableEdgeToEdge().
// Older devices keep correct padding via Flutter AppBar / SafeArea.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }
}
