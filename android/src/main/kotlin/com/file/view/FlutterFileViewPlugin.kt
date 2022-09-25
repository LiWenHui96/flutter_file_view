package com.file.view

import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import com.tencent.smtt.export.external.TbsCoreSettings
import com.tencent.smtt.sdk.QbSdk
import com.tencent.smtt.sdk.TbsListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterFileViewPlugin */
class FlutterFileViewPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var mFlutterPluginBinding: FlutterPluginBinding? = null

    private var x5Status: X5Status = X5Status.NONE
    private var mContext: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, channelName)
        channel.setMethodCallHandler(this)

        mFlutterPluginBinding = flutterPluginBinding
        mContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "init" -> initX5Engine(call)
            "x5Status" -> result.success(currentX5Status)
            "getTemporaryPath" -> result.success(mContext?.cacheDir?.path)
            else -> result.notImplemented()
        }
    }

    /**
     * Initialize X5 engine
     */
    private fun initX5Engine(call: MethodCall) {
        if (mContext == null || x5Status == X5Status.DONE || x5Status == X5Status.DOWNLOAD_OUT_OF_ONE) {
            return
        }

        // The status at this time is none.
        handleX5StatusMessage(status = X5Status.NONE, msg = "ready for initialization")

        resetQbSdk()

        val canDownloadWithoutWifi: Boolean =
            call.argument<Boolean>("canDownloadWithoutWifi") ?: true
        val canOpenDex2Oat: Boolean = call.argument<Boolean>("canOpenDex2Oat") ?: true

        QbSdk.setDownloadWithoutWifi(canDownloadWithoutWifi)

        if (canOpenDex2Oat) {
            // 在调用TBS初始化、创建WebView之前进行如下配置，以开启优化方案
            val map = HashMap<String, Any>()
            map[TbsCoreSettings.TBS_SETTINGS_USE_SPEEDY_CLASSLOADER] = true
            map[TbsCoreSettings.TBS_SETTINGS_USE_DEXLOADER_SERVICE] = true
            QbSdk.initTbsSettings(map)
        }

        handleX5StatusMessage(
            status = X5Status.START, msg = "Start the initialization of X5"
        )

        QbSdk.setTbsListener(object : TbsListener {
            override fun onDownloadFinish(p0: Int) {
                handleX5StatusMessage(
                    status = when (p0) {
                        100 -> X5Status.DOWNLOAD_SUCCESS
                        110 -> X5Status.DOWNLOAD_NON_REQUIRED
                        127 -> X5Status.DOWNLOAD_OUT_OF_ONE
                        else -> X5Status.DOWNLOAD_FAIL
                    }, msg = "TBS download complete - " + p0 + showStatus(p0 == 100)
                )
            }

            override fun onInstallFinish(p0: Int) {
                handleX5StatusMessage(
                    status = if (p0 == 200) X5Status.INSTALL_SUCCESS else X5Status.INSTALL_FAIL,
                    msg = "TBS installation completed - " + p0 + showStatus(p0 == 200)
                )
            }

            override fun onDownloadProgress(p0: Int) {
                handleX5StatusMessage(
                    status = X5Status.DOWNLOADING, msg = "TBS download progress: $p0"
                )
                runMainThread(obj = p0, method = "x5DownloadProgress")
            }
        })

        QbSdk.initX5Environment(mContext, onQbSdkPreInitCallback)
        Log.i(
            TAG,
            "Whether the app actively disables the X5 kernel: " + QbSdk.getIsSysWebViewForcedByOuter()
        )
    }

    private val onQbSdkPreInitCallback: QbSdk.PreInitCallback = object : QbSdk.PreInitCallback {
        override fun onCoreInitFinished() {
            Log.i(TAG, "TBS kernel initialized")
        }

        override fun onViewInitFinished(b: Boolean) {
            if (!b) resetQbSdk()

            handleX5StatusMessage(
                status = if (b) X5Status.DONE else X5Status.ERROR,
                msg = "TBS kernel initialization" + showStatus(b) + " - " + QbSdk.canLoadX5(
                    mContext
                )
            )
        }
    }

    /**
     * Reset QbSdk
     */
    private fun resetQbSdk() {
        if (!QbSdk.canLoadX5(mContext)) {
            QbSdk.reset(mContext)
        }
    }

    /**
     * Send a message to Flutter.
     */
    private fun runMainThread(obj: Int, method: String) {
        val message = handler.obtainMessage()

        val bundle = Bundle()
        bundle.putString("method", method)
        bundle.putInt("value", obj)
        message.data = bundle

        handler.sendMessage(message)
    }

    private val handler: Handler = object : Handler(Looper.myLooper()!!) {
        override fun dispatchMessage(msg: Message) {
            super.dispatchMessage(msg)

            channel.invokeMethod(msg.data.getString("method") ?: "", msg.data.getInt("value"))
        }
    }

    /**
     * Send a message to Flutter.
     *
     * Realize the monitoring of X5 kernel initialization state.
     */
    private fun handleX5StatusMessage(status: X5Status, msg: String) {
        x5Status = status
        runMainThread(status.value, method = "x5Status")
        Log.i(TAG, msg)
    }

    /**
     * @param flag
     * @return
     */
    private fun showStatus(flag: Boolean): String {
        return if (flag) " - SUCCESS" else " - FAIL"
    }

    /**
     * Current status of x5 engine.
     *
     * @return x5Status
     */
    private val currentX5Status: Int
        get() {
            Log.i(TAG, "Get the loaded state of the kernel - $x5Status")
            return x5Status.value
        }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        mFlutterPluginBinding = null
        mContext = null
    }

    companion object {
        val TAG: String = FlutterFileViewPlugin::class.java.name

        const val channelName = "flutter_file_view.io.channel/method"
        const val viewName = "flutter_file_view.io.view/local"
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        // Register here due to TbsReaderView problem.
        if (mFlutterPluginBinding != null) {
            mFlutterPluginBinding!!.platformViewRegistry.registerViewFactory(
                viewName, FileViewFactory(
                    mContext = binding.activity, messenger = mFlutterPluginBinding!!.binaryMessenger
                )
            )
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}
}
