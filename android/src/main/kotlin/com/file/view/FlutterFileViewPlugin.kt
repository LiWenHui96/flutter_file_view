package com.file.view

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import com.tencent.smtt.export.external.TbsCoreSettings
import com.tencent.smtt.sdk.QbSdk
import com.tencent.smtt.sdk.QbSdk.PreInitCallback
import com.tencent.smtt.sdk.TbsDownloader
import com.tencent.smtt.sdk.TbsListener

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * FlutterFileViewPlugin
 */
class FlutterFileViewPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var channel: MethodChannel? = null

    // 状态值
    var initX5Status: Int = X5Status.INIT
    private var nowDownCount = 0
    private var mFlutterPluginBinding: FlutterPluginBinding? = null
    private var mContext: Context? = null
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, channelName)
        channel!!.setMethodCallHandler(this)
        mFlutterPluginBinding = flutterPluginBinding
        mContext = mFlutterPluginBinding!!.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android " + Build.VERSION.RELEASE)
            "getX5Status" -> result.success(x5Status)
            "manualInitX5" -> manualInitX5()
            else -> result.notImplemented()
        }
    }

    /**
     * 初始化 X5
     */
    private fun initX5() {
        val handler: Handler = object : Handler(Looper.myLooper()!!) {
            override fun dispatchMessage(msg: Message) {
                super.dispatchMessage(msg)
                channel!!.invokeMethod("x5Status", x5Status)
            }
        }
        handleMessage(handler)
        if (mContext == null) {
            return
        }
        Log.e(TAG, "开始初始化X5")

        // 更改初始化状态
        initX5Status = X5Status.INIT_LOADING
        handleMessage(handler)

        /// 不获取 AndroidID
        QbSdk.canGetAndroidId(false)
        /// 不获取 IMEI（设备识别码）
        QbSdk.canGetDeviceId(false)
        /// 不获取 IMSI（用户识别码）
        QbSdk.canGetSubscriberId(false)
        resetQbSdk()

        // 在调用TBS初始化、创建WebView之前进行如下配置，以开启优化方案
        val map = HashMap<String, Any>()
        map[TbsCoreSettings.TBS_SETTINGS_USE_SPEEDY_CLASSLOADER] = true
        map[TbsCoreSettings.TBS_SETTINGS_USE_DEXLOADER_SERVICE] = true
        QbSdk.initTbsSettings(map)
        QbSdk.setDownloadWithoutWifi(true)
        QbSdk.setTbsListener(object : TbsListener {
            override fun onDownloadFinish(i: Int) {
                initX5Status = if (i == 100 || i == 0) X5Status.DOWNLOAD_SUCCESS else X5Status.DOWNLOAD_FAIL
                handleMessage(handler)
                Log.e(TAG, "TBS下载完成 - " + i + " - " + showStatus(i == 100 || i == 0))
                if (initX5Status == X5Status.DOWNLOAD_FAIL && nowDownCount <= maxDownCount) {
                    // 下载失败后，尝试重新下载
                    TbsDownloader.startDownload(mContext)
                    nowDownCount++
                }
            }

            override fun onInstallFinish(i: Int) {
                initX5Status = if (i == 200) X5Status.INSTALL_SUCCESS else X5Status.INSTALL_FAIL
                handleMessage(handler)
                Log.e(TAG, "TBS安装完成 - " + i + " - " + showStatus(i == 200))
            }

            override fun onDownloadProgress(i: Int) {
                initX5Status = if (i in 1..100) X5Status.DOWNLOAD_LOADING else X5Status.DOWNLOAD_FAIL
                Log.e(TAG, "TBS下载进度:$i")
            }
        })
        val onQbSdkPreInitCallback: PreInitCallback = object : PreInitCallback {
            override fun onCoreInitFinished() {
                Log.e(TAG, "TBS内核初始化完毕")
            }

            override fun onViewInitFinished(b: Boolean) {
                initX5Status = if (b) X5Status.SUCCESS else X5Status.FAIL
                handleMessage(handler)
                if (!b) {
                    resetQbSdk()
                }
                Log.e(TAG, "TBS内核初始化" + showStatus(b) + " - " + QbSdk.canLoadX5(mContext))
            }
        }

        // X5内核初始化
        QbSdk.initX5Environment(mContext, onQbSdkPreInitCallback)
        Log.e(TAG, "app是否主动禁用了X5内核: " + QbSdk.getIsSysWebViewForcedByOuter())
    }

    /**
     * 发送消息，主要用于在其他线程时可以在主线程发送消息给Flutter
     * 实现X5内核初始化监听
     */
    private fun handleMessage(handler: Handler) {
        val message = handler.obtainMessage()
        handler.sendMessage(message)
    }

    /**
     * 显示 状态
     *
     * @param flag
     * @return
     */
    private fun showStatus(flag: Boolean): String {
        return if (flag) "成功" else "失败"
    }

    /**
     * 重置 QbSdk
     */
    private fun resetQbSdk() {
        initX5Status = if (mContext != null && !QbSdk.canLoadX5(mContext)) {
            // 重置
            QbSdk.reset(mContext)
            X5Status.INIT
        } else {
            X5Status.SUCCESS
        }
    }

    /**
     * 获取X5初始化状态
     *
     * @return
     */
    private val x5Status: Int
        get() {
            Log.e(TAG, "获取内核加载状态 - $initX5Status")
            return initX5Status
        }

    /**
     * 初始化 X5内核
     */
    private fun manualInitX5() {
        if (mContext == null) {
            return
        }

        // 正在初始化 / 内核加载完成 / 下载完成 / 正在下载 / 其他状态，无须重复操作
        // 仅处理 未初始化 / 初始化失败 / 下载失败 的情况
        if (initX5Status == X5Status.INIT) {
            initX5()
        } else if (initX5Status == X5Status.FAIL) {
            if (!QbSdk.canLoadX5(mContext)) {
                initX5()
            }
        } else if (initX5Status == X5Status.DOWNLOAD_FAIL) {
            TbsDownloader.startDownload(mContext)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        // 清空数据
        channel!!.setMethodCallHandler(null)
        mFlutterPluginBinding = null
        mContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.e(TAG, "onAttachedToActivity")

        // App启动时，开始初始化X5内核
        initX5()

        // 因TbsReaderView问题，故在此注册
        mFlutterPluginBinding!!.platformViewRegistry.registerViewFactory(viewName,
                FileLocalViewFactory(mFlutterPluginBinding!!.binaryMessenger, binding.activity))
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.e(TAG, "onDetachedFromActivityForConfigChanges")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.e(TAG, "onReattachedToActivityForConfigChanges")
    }

    override fun onDetachedFromActivity() {
        Log.e(TAG, "onDetachedFromActivity")
    }

    companion object {
        val TAG: String = FlutterFileViewPlugin::class.java.name

        // 尝试重新下载的次数
        private const val maxDownCount = 10
        const val channelName = "flutter_file_view.io.method"
        const val viewName = "plugins.file_local_view/view"
    }
}

