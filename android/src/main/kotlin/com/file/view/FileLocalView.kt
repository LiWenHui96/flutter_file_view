package com.file.view

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import com.tencent.smtt.sdk.TbsReaderView
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import java.io.File

/**
 * @Author: LiWeNHuI
 * @Date: 2021/10/22
 * @Describe:
 */
class FileLocalView internal constructor(context: Context, viewId: Int, args: Map<String, Any>, messenger: BinaryMessenger?) : PlatformView, MethodCallHandler, TbsReaderView.ReaderCallback {
    private var mTbsReaderView: TbsReaderView?
    private var channel: MethodChannel?
    private val tempPrefixPath: String
    private var filePath: String? = ""
    private var fileType: String? = ""
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if ("openFile" == call.method) {
            if (isSupportFile()) {
                openFile()
                result.success(true)
            } else {
                result.success(false)
            }
        }
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
        bundle.putString("filePath", filePath)
        bundle.putBoolean("is_bar_show", false)
        bundle.putBoolean("menu_show", false)
        bundle.putBoolean("is_bar_animating", false)
        bundle.putString("tempPath", tempPrefixPath)
        mTbsReaderView!!.openFile(bundle)
    }

    /**
     * Determine whether the file can be opened
     *
     * @return
     */
    private fun isSupportFile(): Boolean {
        return mTbsReaderView!!.preOpen(fileType, false)
    }

    override fun onCallBackAction(integer: Int?, o: Any?, o1: Any?) {}
    override fun getView(): View? {
        return mTbsReaderView
    }

    override fun dispose() {
        Log.e(TAG, "FileLocalView dispose")
        mTbsReaderView!!.onStop()
        mTbsReaderView = null
        channel!!.setMethodCallHandler(null)
        channel = null
    }

    companion object {
        val TAG: String = FileLocalView::class.java.name
    }

    init {
        Log.e(TAG, "FileLocalView start")
        tempPrefixPath = context.cacheDir.toString() + File.separator + "TbsFileReaderTmp"
        if (args.containsKey("filePath")) {
            filePath = args["filePath"] as String
        }
        if (args.containsKey("fileType")) {
            fileType = args["fileType"] as String
        }
        channel = MethodChannel(messenger, FlutterFileViewPlugin.channelName + "_" + viewId)
        channel!!.setMethodCallHandler(this)
        mTbsReaderView = TbsReaderView(context, this)
        mTbsReaderView!!.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
    }
}
