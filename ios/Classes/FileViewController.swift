import UIKit
import QuickLook

class FileViewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
  var filePath: String = ""
  
  func setFilePath(filePath: String) {
    self.filePath = filePath
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let previewController = QLPreviewController()
    previewController.view.frame = self.view.frame
    previewController.dataSource = self
    previewController.delegate = self
    self.addChild(previewController)
    self.view.addSubview(previewController.view)
  }
  
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    return 1
  }

  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    let url = URL(fileURLWithPath: self.filePath)
    return url as QLPreviewItem
  }

  func previewControllerWillDismiss(_ controller: QLPreviewController) {
    print("将要关闭之前调用")
  }
      
  func previewControllerDidDismiss(_ controller: QLPreviewController) {
    print("关闭之后调用")
  }
}
