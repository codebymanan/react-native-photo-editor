import UIKit
import ZLImageEditor

@objc(PhotoEditorManager)
public class PhotoEditorManager: NSObject {

  @objc public static func open(
    _ path: String,
    stickers: [String],
    resolve: @escaping (String) -> Void,
    reject: @escaping (String, String) -> Void
  ) {
    loadImage(path) { image in
      DispatchQueue.main.async {
        guard let image else {
          reject("E_FAILED", "Could not load image: \(path)")
          return
        }
        guard let presenter = topViewController() else {
          reject("E_NO_ACTIVITY", "No view controller available to present the editor")
          return
        }

        ZLImageEditorConfiguration.default()
          .editImageTools([.draw, .clip, .textSticker, .mosaic, .filter, .adjust])
          .adjustTools([.brightness, .contrast, .saturation])

        let editor = ZLEditImageViewController(image: image)
        editor.modalPresentationStyle = .fullScreen
        editor.editFinishBlock = { resImage, _ in
          saveImage(resImage, resolve: resolve, reject: reject)
        }
        editor.cancelBlock = {
          reject("E_CANCELLED", "User cancelled image editing")
        }
        presenter.present(editor, animated: true)
      }
    }
  }

  private static func loadImage(_ path: String, completion: @escaping (UIImage?) -> Void) {
    if path.hasPrefix("http://") || path.hasPrefix("https://") {
      guard let url = URL(string: path) else {
        completion(nil)
        return
      }
      URLSession.shared.dataTask(with: url) { data, _, _ in
        completion(data.flatMap(UIImage.init(data:)))
      }.resume()
    } else {
      let filePath = path.hasPrefix("file://") ? String(path.dropFirst(7)) : path
      completion(UIImage(contentsOfFile: filePath))
    }
  }

  private static func saveImage(
    _ image: UIImage,
    resolve: @escaping (String) -> Void,
    reject: @escaping (String, String) -> Void
  ) {
    let outputDir = (NSTemporaryDirectory() as NSString).appendingPathComponent("photo_editor")
    do {
      try FileManager.default.createDirectory(
        atPath: outputDir, withIntermediateDirectories: true)
      let outputPath = (outputDir as NSString)
        .appendingPathComponent("\(Int(Date().timeIntervalSince1970 * 1000)).png")
      guard let data = image.pngData() else {
        reject("E_FAILED", "Could not encode edited image")
        return
      }
      try data.write(to: URL(fileURLWithPath: outputPath))
      resolve(outputPath)
    } catch {
      reject("E_FAILED", "Failed to save image: \(error.localizedDescription)")
    }
  }

  private static func topViewController() -> UIViewController? {
    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }

    var top = keyWindow?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}
