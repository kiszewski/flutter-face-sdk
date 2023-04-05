package com.example.haila_display_flutter

import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer


class MainActivity: FlutterActivity() {
    private val CHANNEL = "haila.display.com/face"
    private val service = FaceService()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "initialize") {
                val isInitialized = service.initialize()

                if (isInitialized) {
                    result.success(isInitialized)
                } else {
                    result.error("ERROR", "Not Initialized.", null)
                }
            } else if (call.method == "getTemplateFromPath") {
                val template = service.createTemplateFromPath(call.arguments.toString())

                if (template.isNotEmpty()) {
                    result.success(template)
                } else {
                    result.error("ERROR", "Cannot get template.", null)
                }
            } else if (call.method == "getTemplate") {
                val width = call.argument<Int>("width")
                val height = call.argument<Int>("height")
                val pixels = call.argument<IntArray>("pixels")

                val template = service.createTemplateFromPixels(pixels!!, width!!, height!!)

                if (template.isNotEmpty()) {
                    result.success(template)
                } else {
                    result.error("ERROR", "Cannot get template.", null)
                }
            } else if (call.method == "getTemplateFromBuffer") {
                val width = call.argument<Int>("width")
                val height = call.argument<Int>("height")
                val pixels = call.argument<ByteArray>("pixels")

                val template = service.createTemplate(pixels!!, width!!, height!!)

                if (template.isNotEmpty()) {
                    result.success(template)
                } else {
                    result.error("ERROR", "Cannot get template.", null)
                }
            } else if (call.method == "matchTemplates") {
                val obj = call.arguments as List<ByteArray>
                print(obj)

                val list1 = obj[0]
                val list2 = obj[1]

                print("BYTE ARRAY CONVERTED")

                val res = service.matchTemplates(list1, list2)

                result.success(res)
            } else {
                result.notImplemented()
            }
        }
    }
}
