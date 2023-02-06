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
            "init" -> initTbs(call)
            "x5Status" -> result.success(currentX5Status)
            "getTemporaryPath" -> result.success(mContext?.cacheDir?.path)
            else -> result.notImplemented()
        }
    }

    /**
     * Initialize TBS
     */
    private fun initTbs(call: MethodCall?) {
        if (canLoadX5(mContext)) {
            sendMessage(status = X5Status.DONE, msg = "Core Init" + showStatus(flag = true))
            return
        }

        // The status at this time is none.
        sendMessage(status = X5Status.NONE, msg = "Ready to initialize.")

        val canDownloadWithoutWifi: Boolean =
            call?.argument<Boolean>("canDownloadWithoutWifi") ?: true
        val canOpenDex2Oat: Boolean = call?.argument<Boolean>("canOpenDex2Oat") ?: true

        // 在调用TBS初始化、创建WebView之前进行如下配置，以开启优化方案
        val map = HashMap<String, Any>()
        map[TbsCoreSettings.TBS_SETTINGS_USE_SPEEDY_CLASSLOADER] = true
        map[TbsCoreSettings.TBS_SETTINGS_USE_DEXLOADER_SERVICE] = true

        QbSdk.setDownloadWithoutWifi(canDownloadWithoutWifi)
        if (canOpenDex2Oat) QbSdk.initTbsSettings(map)

        sendMessage(status = X5Status.START, msg = "Start the initialization.")

        QbSdk.initX5Environment(mContext, object : QbSdk.PreInitCallback {
            override fun onCoreInitFinished() {
                log(msg = "onCoreInitFinished")
            }

            override fun onViewInitFinished(b: Boolean) {
                if (!b) {
                    QbSdk.setDownloadWithoutWifi(canDownloadWithoutWifi)
                    if (canOpenDex2Oat) QbSdk.initTbsSettings(map)

                    QbSdk.reset(mContext)
                }


                sendMessage(
                    status = if (b) X5Status.DONE else X5Status.ERROR,
                    msg = "Core Init" + showStatus(b)
                )
            }
        })

        QbSdk.setTbsListener(object : TbsListener {
            override fun onDownloadFinish(p0: Int) {
                sendMessage(
                    status = when (p0) {
                        100 -> X5Status.DOWNLOAD_SUCCESS
                        110 -> X5Status.DOWNLOAD_NON_REQUIRED
                        111 -> X5Status.DOWNLOAD_CANCEL_NOT_WIFI
                        127 -> X5Status.DOWNLOAD_OUT_OF_ONE
                        133 -> X5Status.DOWNLOAD_CANCEL_REQUESTING
                        -122 -> X5Status.DOWNLOAD_NO_NEED_REQUEST
                        -134 -> X5Status.DOWNLOAD_FLOW_CANCEL
                        else -> X5Status.DOWNLOAD_FAIL
                    },
                    msg = "Download completed - " + p0 + showStatus(p0 == 100),
                )
            }

            override fun onInstallFinish(p0: Int) {
                sendMessage(
                    status = if (p0 == 200) X5Status.INSTALL_SUCCESS else X5Status.INSTALL_FAIL,
                    msg = "Installation completed - " + p0 + showStatus(p0 == 200)
                )
            }

            override fun onDownloadProgress(p0: Int) {
                sendMessage(status = X5Status.DOWNLOADING, msg = "Download Progress: $p0%")
                runMainThread(obj = p0, method = "X5DownloadProgress")
            }
        })
    }

    /**
     * Verify that X5 has been successfully loaded locally or context is not empty.
     * 检验本地是否已成功加载了X5 or context 不为空。
     */
    private fun canLoadX5(context: Context?): Boolean {
        return if (context == null) false else QbSdk.isX5Core()
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
    private fun sendMessage(status: X5Status, msg: String) {
        if (status != x5Status) {
            x5Status = status
            runMainThread(status.value, method = "x5Status")
        }

        log(msg = msg)
    }

    private fun log(msg: String) {
        Log.d(TAG, "FlutterFileView: TBS - $msg")
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
            log(msg = "Current Status - $x5Status")
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
