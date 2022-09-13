import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

/// @Describe: File network view component
///
/// @Author: LiWeNHuI
/// @Date: 2022/2/15

class NetworkFileViewer extends StatefulWidget {
  const NetworkFileViewer({
    Key? key,
    required this.downloadUrl,
    required this.downloadPath,
    required this.onViewPressed,
    this.placeholder,
    this.fileSizeData,
    this.fileSizeQueryParameters,
    this.fileSizeOptions,
    this.fileSizeTip,
    this.fileSizeFailTip,
    this.fileSizeErrorTip,
    this.downloadQueryParameters,
    this.downloadDeleteOnError,
    this.downloadLengthHeader,
    this.downloadData,
    this.downloadOptions,
    this.fileNameStyle,
    this.fileSizeStyle,
    this.downloadTitle,
    this.viewTitle,
    this.buttonStyle,
    this.btnTitleColor,
    this.btnBgColor,
    this.progressSize,
    this.progressStrokeWidth,
    this.progressBackgroundColor,
    this.progressValueColor,
  }) : super(key: key);

  /// Download link for file
  /// [downloadUrl] will be used to obtain the file name and type
  final String downloadUrl;

  /// The file storage address is used to determine whether the file can be downloaded
  final String downloadPath;

  /// File viewing function
  /// Will be removed in future releases
  final VoidCallback onViewPressed;

  /// Widget displayed while the target [downloadUrl] is loading.
  final Widget? placeholder;

  /// Relevant parameters of the request to get the size of the file
  final dynamic fileSizeData;
  final Map<String, dynamic>? fileSizeQueryParameters;
  final Options? fileSizeOptions;
  final String? fileSizeTip;
  final String? fileSizeFailTip;
  final String? fileSizeErrorTip;

  /// Relevant parameters of the request to downloading files
  final Map<String, dynamic>? downloadQueryParameters;
  final bool? downloadDeleteOnError;
  final String? downloadLengthHeader;
  final dynamic downloadData;
  final Options? downloadOptions;

  /// The style of the displayed file name
  final TextStyle? fileNameStyle;

  /// The style of the displayed file size
  final TextStyle? fileSizeStyle;

  /// The text displayed on the button
  final String? downloadTitle;
  final String? viewTitle;

  /// The style of button
  final ButtonStyle? buttonStyle;
  final Color? btnTitleColor;
  final Color? btnBgColor;

  /// The style of progress bar
  final double? progressSize;
  final double? progressStrokeWidth;
  final Color? progressBackgroundColor;
  final Color? progressValueColor;

  @override
  State<NetworkFileViewer> createState() => _NetworkFileViewerState();
}

class _NetworkFileViewerState extends State<NetworkFileViewer> {
  late ViewerLocalizations local = ViewerLocalizations.of(context);

  /// Does it support downloading
  late bool isDownload = !FileTool.isExistsFile(filePath);

  /// Download progress
  double progressValue = 0.0;

  /// File size
  String fileSize = '';

  ViewType viewType = ViewType.none;

  final CancelToken cancelToken = CancelToken();

  @override
  void initState() {
    super.initState();

    Future<void>.delayed(Duration.zero, () {
      getViewType();
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (!cancelToken.isCancelled) {
      cancelToken.cancel('The page is closed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (viewType == ViewType.done) {
      return _buildBodyWidget();
    } else {
      return _buildPlaceholderWidget();
    }
  }

  Widget _buildPlaceholderWidget() {
    return widget.placeholder ?? baseIndicator(context);
  }

  Widget _buildBodyWidget() {
    return Column(
      children: <Widget>[
        centerWidget(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildTopWidget(),
          ),
        ),
        centerWidget(
          child:
              progressValue > 0 ? _buildProgressWidget() : _buildButtonWidget(),
        ),
      ],
    );
  }

  List<Widget> _buildTopWidget() {
    return <Widget>[
      Image.asset(fileTypeImage, package: packageName, width: 48, height: 48),
      Container(
        margin: const EdgeInsets.only(top: 40.0, bottom: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Text(
          fileName,
          textAlign: TextAlign.center,
          style: widget.fileNameStyle ??
              Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      Text(
        fileSize,
        style: widget.fileSizeStyle ?? Theme.of(context).textTheme.bodyText2,
      ),
    ];
  }

  Widget _buildButtonWidget() {
    final double screenWidth = MediaQuery.of(context).size.width;
    double defaultWidth = screenWidth / 3;
    defaultWidth = defaultWidth < 120 ? 120 : defaultWidth;
    double defaultHeight = defaultWidth / 3;
    defaultHeight = defaultHeight < 40 ? 40 : defaultHeight;

    final Size size = Size(defaultWidth, defaultHeight);

    return ElevatedButton(
      onPressed: () async =>
          isDownload ? download() : widget.onViewPressed.call(),
      style: widget.buttonStyle ??
          ButtonStyle(
            foregroundColor:
                MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              return widget.btnTitleColor ?? Colors.white;
            }),
            backgroundColor:
                MaterialStateProperty.resolveWith((Set<MaterialState> states) {
              // 当按钮无法点击时 设置背景色
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey[350];
              } else {
                return widget.btnBgColor ?? Theme.of(context).primaryColor;
              }
            }),
            minimumSize: MaterialStateProperty.all(size),
          ),
      child: Text(btnName),
    );
  }

  Widget _buildProgressWidget() {
    final double size = widget.progressSize ?? 60.0;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: progressValue,
        strokeWidth: widget.progressStrokeWidth ?? 6.0,
        backgroundColor:
            widget.progressBackgroundColor ?? Theme.of(context).primaryColor,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.progressValueColor ?? Colors.tealAccent,
        ),
      ),
    );
  }

  Widget centerWidget({required Widget child}) {
    return Expanded(child: Center(child: child));
  }

  /// Download
  Future<DownloadStatus> download() async {
    await FlutterFileView.downloadFile(
      fileLink,
      filePath,
      callback: (DownloadStatus status) {
        setState(() {
          if (mounted) {
            isDownload = !(status == DownloadStatus.done);
            progressValue = 0.0;
          }
        });
      },
      onProgress: (int count, int total) async {
        setState(() {
          if (mounted) {
            progressValue = count / total;
          }
        });
      },
      queryParameters: widget.downloadQueryParameters,
      cancelToken: cancelToken,
      deleteOnError: widget.downloadDeleteOnError,
      lengthHeader: widget.downloadLengthHeader,
      data: widget.downloadData,
      options: widget.downloadOptions,
    );
    return DownloadStatus.none;
  }

  /// Display different layouts by changing status
  Future<void> getViewType() async {
    final String? size = await FlutterFileView.getFileSize(
      context,
      fileLink,
      data: widget.fileSizeData,
      queryParameters: widget.fileSizeQueryParameters,
      cancelToken: cancelToken,
      options: widget.fileSizeOptions,
      fileSizeTip: widget.fileSizeTip,
      fileSizeErrorTip: widget.fileSizeErrorTip,
      fileSizeFailTip: widget.fileSizeFailTip,
    );

    setState(() {
      if (mounted) {
        fileSize = size ?? '';
        viewType = ViewType.done;
      }
    });
  }

  String get btnName {
    return isDownload
        ? widget.downloadTitle ?? local.downloadTitle
        : widget.viewTitle ?? local.viewTitle;
  }

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
      default:
        type += 'ic_file_other.png';
        break;
    }

    return type;
  }

  String get fileLink => widget.downloadUrl;

  String get filePath => widget.downloadPath;

  String get fileName => FileTool.getFileName(fileLink);

  String get fileType => FileTool.getFileType(fileLink);
}
