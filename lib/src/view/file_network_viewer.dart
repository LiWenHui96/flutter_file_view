import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

///
/// @Describe: File network view component
///
/// @Author: LiWeNHuI
/// @Date: 2021/9/14
///

class FileNetworkViewer extends StatefulWidget {
  const FileNetworkViewer({
    Key? key,
    required this.downloadUrl,
    required this.downloadPath,
    required this.onViewPressed,
    this.fileShowName,
    this.fileType,
    this.fileNameStyle,
    this.fileSizeStyle,
    this.downloadTitle,
    this.viewTitle,
    this.btnTitleColor,
    this.btnBgColor,
    this.borderSide,
  }) : super(key: key);

  ///
  /// Download link for file
  /// [downloadUrl] will be used to obtain the file name and type
  ///
  /// 文件下载链接
  /// 使用[downloadUrl]获取文件名称以及类型
  ///
  final String downloadUrl;

  ///
  /// The file storage address is used to determine whether the file can be downloaded
  ///
  /// 文件存储地址，并用于确定文件是否可以下载
  ///
  final String downloadPath;

  ///
  /// File viewing function
  /// Will be removed in future releases
  ///
  /// 文件查看功能
  /// 将在未来的版本中删除
  ///
  final VoidCallback onViewPressed;

  @Deprecated(
    'Use downloadUrl instead. '
    'This feature was deprecated after v1.2.0',
  )
  final String? fileShowName;

  @Deprecated(
    'Use downloadUrl instead. '
    'This feature was deprecated after v1.2.0',
  )
  final String? fileType;

  ///
  /// The style of the displayed file name
  ///
  /// 所展示文件名称的风格
  ///
  final TextStyle? fileNameStyle;

  ///
  /// The style of the text showing the size of the file resource
  ///
  /// 所展示文件资源大小的文字的风格
  ///
  final TextStyle? fileSizeStyle;

  ///
  /// The style of the button
  ///
  /// 按钮样式
  ///
  final String? downloadTitle;
  final String? viewTitle;
  final Color? btnTitleColor;
  final Color? btnBgColor;
  final BorderSide? borderSide;

  @override
  _FileNetworkViewerState createState() => _FileNetworkViewerState();
}

class _FileNetworkViewerState extends State<FileNetworkViewer> {
  EViewStatus eViewStatus = EViewStatus.loading;

  /// Does it support downloading
  bool isDownload = true;

  /// Show download progress bar
  bool isShowProgress = false;

  /// Download progress
  double progressValue = 0.0;

  /// File size
  String fileSize = '计算中...';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((callback) {
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (eViewStatus == EViewStatus.loading) {
      return _buildLoadWidget();
    } else if (eViewStatus == EViewStatus.success) {
      return _buildBodyWidget();
    } else {
      return _buildLoadWidget();
    }
  }

  Widget _buildLoadWidget() {
    return const Center(child: CupertinoActivityIndicator(radius: 14.0));
  }

  Widget _buildBodyWidget() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildTopWidget(),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: isShowProgress ? _buildProgress() : _buildButtonWidget(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTopWidget() {
    return <Widget>[
      Image.asset(
        fileTypeImage,
        package: 'flutter_file_view',
        width: 48,
        height: 48,
      ),
      Container(
        margin: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        child: Text(
          fileName,
          style: widget.fileNameStyle ??
              const TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      Text(
        fileSize,
        style:
            widget.fileSizeStyle ?? const TextStyle(color: Color(0xFF333333)),
      ),
    ];
  }

  ///
  /// Download Button
  ///
  Widget _buildButtonWidget() {
    double screenWidth = MediaQuery.of(context).size.width;
    double defaultWidth = screenWidth / 3.5;
    defaultWidth = defaultWidth < 120 ? 120 : defaultWidth;
    double defaultHeight = defaultWidth / 3;
    defaultHeight = defaultHeight < 40 ? 40 : defaultHeight;

    return ElevatedButton(
      onPressed: () async {
        if (isDownload) {
          await _download();
        } else {
          widget.onViewPressed();
        }
      },
      child: Text(btnName),
      style: ButtonStyle(
        // 设置按钮上字体与图标的颜色
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          return widget.btnTitleColor ?? Colors.white;
        }),
        // 背景颜色
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          // 当按钮无法点击时 设置背景色
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey[350];
          } else {
            return widget.btnBgColor ?? Theme.of(context).primaryColor;
          }
        }),
        // 设置水波纹颜色
        overlayColor: MaterialStateProperty.all(Colors.black26),
        // 设置阴影
        elevation: MaterialStateProperty.all(0),
        //设置按钮的大小
        minimumSize:
            MaterialStateProperty.all(Size(defaultWidth, defaultHeight)),
        //设置边框
        side: widget.borderSide == null
            ? null
            : MaterialStateProperty.all(widget.borderSide),
      ),
    );
  }

  ///
  /// Download Progress
  ///
  Widget _buildProgress() {
    return SizedBox(
      width: 48.0,
      height: 48.0,
      child: CircularProgressIndicator(
        value: progressValue,
        strokeWidth: 8.0,
        backgroundColor: Theme.of(context).primaryColor,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.tealAccent),
      ),
    );
  }

  ///
  /// Download File
  ///
  Future<void> _download() async {
    setState(() {
      if (mounted) isShowProgress = true;
    });

    DownloadStatus status = await DownloadTool.downloadFile(fileLink, filePath,
        onProgress: (count, total) async {
      setState(() {
        if (mounted) progressValue = count / total;
      });
    });

    setState(() {
      if (mounted) {
        if (status == DownloadStatus.success) {
          isDownload = false;
        } else {
          isDownload = true;
        }

        isShowProgress = false;
        progressValue = 0.0;
      }
    });
  }

  ///
  /// Obtain the text displayed by the button by judging whether it can be downloaded
  ///
  String get btnName {
    return isDownload
        ? widget.downloadTitle ?? '文件下载'
        : widget.viewTitle ?? '文件查看';
  }

  ///
  /// Data loading
  ///
  /// 数据加载
  ///
  Future<void> loadData() async {
    var result = await Future.wait([
      isDownloadFile(),
      getNetworkFileSize(),
    ]);

    setState(() {
      if (mounted) {
        eViewStatus = EViewStatus.success;

        isDownload = !(result[0] as bool);
        fileSize = result[1] as String;
      }
    });
  }

  ///
  /// Judge whether the file can be downloaded
  ///
  /// 判断文件是否可以下载
  ///
  Future<bool> isDownloadFile() async {
    return await FileTool.isExistsFile(filePath);
  }

  ///
  /// Get network file size
  ///
  /// 获取网络文件大小
  ///
  Future<String> getNetworkFileSize() async {
    return await FlutterFileView.getFileSizeByNet(fileLink);
  }

  ///
  /// Picture displayed by file type
  ///
  /// 按文件类型显示的图片
  ///
  String get fileTypeImage {
    String type = 'assets/images/';
    switch (fileType) {
      case 'doc':
      case 'docx':
        type += 'ic_file_doc.png';
        break;
      case 'xls':
      case 'xlsx':
        type += 'ic_file_xls.png';
        break;
      case 'ppt':
      case 'pptx':
        type += 'ic_file_ppt.png';
        break;
      case 'txt':
        type += 'ic_file_txt.png';
        break;
      case 'pdf':
        type += 'ic_file_pdf.png';
        break;
      case 'zip':
      case 'rar':
      case '7z':
        type += 'ic_file_zip.png';
        break;
      case 'mp4':
      case 'mov':
      case 'avi':
        type += 'ic_file_video.png';
        break;
      case 'mp3':
      case 'wav':
        type += 'ic_file_music.png';
        break;
      default:
        type += 'ic_file_other.png';
        break;
    }

    return type;
  }

  ///
  /// Links to files
  ///
  /// 文件链接
  ///
  String get fileLink => widget.downloadUrl;

  ///
  /// Path to file
  ///
  /// 文件路径
  ///
  String get filePath => widget.downloadPath;

  ///
  /// Name of the file
  ///
  /// 文件名称
  ///
  String get fileName => FileTool.getFileName(fileLink);

  ///
  /// Type of file
  ///
  /// 文件类型
  ///
  String get fileType => FileTool.getFileType(fileLink);
}
