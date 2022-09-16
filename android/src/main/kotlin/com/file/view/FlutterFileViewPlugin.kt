package com.file.view

import android.content.Context
import android.os.*
import android.util.Log
import androidx.annotation.NonNull
import com.tencent.smtt.export.external.TbsCoreSettings
import com.tencent.smtt.sdk.*

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.*
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.*

/** FlutterFileViewPlugin */
class FlutterFileViewPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var mFlutterPluginBinding: FlutterPluginBinding? = null

    private var x5Status: Int = X5Status.NONE
    private var mContext: Context? = null
    private var nowDownCount = 0

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, channelName)
        channel.setMethodCallHandler(this)

        mFlutterPluginBinding = flutterPluginBinding
        mContext = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initX5" -> x5Start()
            "getX5Status" -> result.success(nowX5Status)
            "manualInitX5" -> manualInitX5()
            else -> result.notImplemented()
        }
    }

    /**
     * Initialize X5
     */
    private fun x5Start() {
        if (mContext == null) {
            return
        }

        handleMessage(handler)

        Log.i(TAG, "Start the initialization of X5")
        x5Status = X5Status.START
        handleMessage(handler)

        resetQbSdk()

        QbSdk.canGetAndroidId(false)
        QbSdk.canGetDeviceId(false)
        QbSdk.canGetSubscriberId(false)
        QbSdk.disableSensitiveApi()

        // 在调用TBS初始化、创建WebView之前进行如下配置，以开启优化方案
        val map = HashMap<String, Any>()
        map[TbsCoreSettings.TBS_SETTINGS_USE_SPEEDY_CLASSLOADER] = true
        map[TbsCoreSettings.TBS_SETTINGS_USE_DEXLOADER_SERVICE] = true
        QbSdk.initTbsSettings(map)

        // Downloadable on mobile network
        QbSdk.setDownloadWithoutWifi(true)

        QbSdk.setTbsListener(object : TbsListener {
            override fun onDownloadFinish(i: Int) {
                x5Status =
                    if (i == 100 || i == 0) X5Status.DOWNLOAD_SUCCESS else X5Status.DOWNLOAD_FAIL
                handleMessage(handler)
                Log.i(TAG, "TBS download complete - " + i + showStatus(i == 100 || i == 0))
                if (x5Status == X5Status.DOWNLOAD_FAIL && nowDownCount <= maxDownCount) {
                    // After the download fails, try downloading again.
                    TbsDownloader.startDownload(mContext)
                    nowDownCount++
                }
            }

            override fun onInstallFinish(i: Int) {
                x5Status = if (i == 200) X5Status.INSTALL_SUCCESS else X5Status.INSTALL_FAIL
                handleMessage(handler)
                Log.i(TAG, "TBS installation completed - " + i + showStatus(i == 200))
            }

            override fun onDownloadProgress(i: Int) {
                x5Status =
                    if (i in 1..100) X5Status.DOWNLOADING else X5Status.DOWNLOAD_FAIL
                Log.i(TAG, "TBS download progress: $i")
            }
        })

        QbSdk.initX5Environment(mContext, onQbSdkPreInitCallback)
        Log.i(
            TAG,
            "Whether the app actively disables the X5 kernel: " + QbSdk.getIsSysWebViewForcedByOuter()
        )
    }

    /**
     * Reset QbSdk
     */
    private fun resetQbSdk() {
        x5Status = if (mContext != null && !QbSdk.canLoadX5(mContext)) {
            QbSdk.reset(mContext)
            X5Status.START
        } else {
            X5Status.DONE
        }
    }

    /**
     * Send a message to Flutter.
     *
     * Realize the monitoring of X5 kernel initialization state
     */
    private fun handleMessage(handler: Handler) {
        val message = handler.obtainMessage()
        handler.sendMessage(message)
    }

    private val handler: Handler = object : Handler(Looper.myLooper()!!) {
        override fun dispatchMessage(msg: Message) {
            super.dispatchMessage(msg)

            channel.invokeMethod("x5Status", x5Status)
        }
    }

    private val onQbSdkPreInitCallback: QbSdk.PreInitCallback = object : QbSdk.PreInitCallback {
        override fun onCoreInitFinished() {
            Log.i(TAG, "TBS kernel initialized")
        }

        override fun onViewInitFinished(b: Boolean) {
            x5Status = if (b) X5Status.DONE else X5Status.ERROR
            handleMessage(handler)
            if (!b) {
                resetQbSdk()
            }
            Log.i(
                TAG,
                "TBS kernel initialization" + showStatus(b) + " - " + QbSdk.canLoadX5(mContext)
            )
        }
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
    private val nowX5Status: Int
        get() {
            Log.i(TAG, "Get the loaded state of the kernel - $x5Status")
            return x5Status
        }

    /**
     * Manual initialization
     */
    private fun manualInitX5() {
        if (mContext == null) {
            return
        }

        // Initializing / Kernel Loading Complete / Downloading Complete / Downloading / Other Status, no need to repeat
        // Only handle uninitialized / failed to initialize / failed to download
        if (x5Status == X5Status.NONE) {
            x5Start()
        } else if (x5Status == X5Status.ERROR) {
            if (!QbSdk.canLoadX5(mContext)) {
                x5Start()
            }
        } else if (x5Status == X5Status.DOWNLOAD_FAIL) {
            TbsDownloader.startDownload(mContext)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        mFlutterPluginBinding = null
        mContext = null
    }

    companion object {
        val TAG: String = FlutterFileViewPlugin::class.java.name

        // Number of times to try to redownload.
        private const val maxDownCount = 10

        const val channelName = "flutter_file_view.io.channel/method"
        const val viewName = "flutter_file_view.io.view/local"
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        // Register here due to TbsReaderView problem.
        if (mFlutterPluginBinding != null) {
            mFlutterPluginBinding!!.platformViewRegistry.registerViewFactory(
                viewName,
                LocalFileViewerFactory(binding.activity, mFlutterPluginBinding!!.binaryMessenger)
            )
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}
}
