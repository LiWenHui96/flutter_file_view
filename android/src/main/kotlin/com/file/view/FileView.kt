package com.file.view

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.tencent.smtt.sdk.TbsReaderView
import com.tencent.smtt.sdk.TbsReaderView.*
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.File

/**
 * @author LiWeNHuI
 * @date 2022/2/15
 * @describe FileView
 */
class FileView internal constructor(
    context: Context,
    messenger: BinaryMessenger,
    viewId: Int,
    args: Map<String, Any>
) : PlatformView, MethodChannel.MethodCallHandler, ReaderCallback {
    private var channel: MethodChannel
    private var mContext: Context
    private var mArgs: Map<String, Any>

    private val tempPrefixPath = context.cacheDir.toString() + File.separator + "TbsFileReaderTmp"

    private var mFrameLayout: FrameLayout? = null
    private var mTbsReaderView: TbsReaderView? = null

    /**
     * Preparations for opening the file
     */
    private fun readyToOpenFile() {
        mTbsReaderView = TbsReaderView(mContext, this)
        mTbsReaderView?.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )

        mFrameLayout?.addView(mTbsReaderView)
        if (isSupportFile()) openFile()
    }

    /**
     * Open File
     */
    private fun openFile() {
        val tempFile = File(tempPrefixPath)
        if (!tempFile.exists() || !tempFile.isDirectory) {
            tempFile.mkdir()
        }

        // 加载文件
        val bundle = Bundle()
        bundle.putString(KEY_FILE_PATH, mArgs[KEY_FILE_PATH] as String)
        bundle.putBoolean(IS_BAR_SHOWING, mArgs[IS_BAR_SHOWING] as Boolean)
        bundle.putBoolean(IS_INTO_DOWNLOADING, mArgs[IS_INTO_DOWNLOADING] as Boolean)
        bundle.putBoolean(IS_BAR_ANIMATING, mArgs[IS_BAR_ANIMATING] as Boolean)
        bundle.putString(KEY_TEMP_PATH, tempPrefixPath)
        mTbsReaderView?.openFile(bundle)
    }

    /**
     * Determine whether the file can be opened
     *
     * @return
     */
    private fun isSupportFile(): Boolean {
        val fileType: String = mArgs["fileType"] as String? ?: return false
        return mTbsReaderView?.preOpen(fileType, false) ?: false
    }

    /**
     * Reset TbsReaderView
     */
    private fun openTbsReaderView(isFirst: Boolean) {
        if (!isFirst) {
            mFrameLayout?.removeView(mTbsReaderView)
            mTbsReaderView?.onStop()
            mTbsReaderView = null

            readyToOpenFile()
            mFrameLayout?.requestLayout()
        }
    }

    override fun getView(): View {
        return mFrameLayout!!
    }

    override fun dispose() {
        Log.i(TAG, "$TAG Dispose")

        mTbsReaderView?.onStop()
        channel.setMethodCallHandler(null)
        mTbsReaderView = null
        mFrameLayout = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "openFile" -> openTbsReaderView(call.arguments() ?: true)
            else -> result.notImplemented()
        }
    }

    override fun onCallBackAction(p0: Int?, p1: Any?, p2: Any?) {
    }

    companion object {
        val TAG: String = FileView::class.java.name
    }

    init {
        mContext = context
        mArgs = args

        channel = MethodChannel(messenger, "${FlutterFileViewPlugin.channelName}_$viewId")
        channel.setMethodCallHandler(this)

        Log.i(TAG, "$TAG Start")

        mFrameLayout = FrameLayout(context)
        mFrameLayout?.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )

        readyToOpenFile()
    }
}