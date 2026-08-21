import UIKit
import ZLImageEditor

@objc(PhotoEditorManager)
public class PhotoEditorManager: NSObject {

  @objc public static func open(
    _ path: String,
    stickers: [String],
    language: String?,
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

        ZLImageEditorUIConfiguration.default()
          .languageType(languageType(for: language))

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

  /// Maps a BCP-47 tag onto the languages the editor ships.
  ///
  /// A missing tag means "follow the device". An unrecognised tag falls back to
  /// English rather than to the device language: the caller explicitly asked not
  /// to use the device setting, so quietly reverting to it would be the one
  /// answer we know they did not want.
  private static func languageType(for tag: String?) -> ZLImageEditorLanguageType {
    guard let tag = tag?.lowercased(), !tag.isEmpty else { return .system }

    // Tolerate the Java-style "pt_BR" spelling as well as BCP-47's "pt-BR".
    let subtags = tag.split(whereSeparator: { $0 == "-" || $0 == "_" }).map(String.init)

    // Chinese needs the script or region, not just the language, to pick a bundle.
    if subtags.first == "zh" {
      let traditional = subtags.dropFirst().contains { ["hant", "tw", "hk", "mo"].contains($0) }
      return traditional ? .chineseTraditional : .chineseSimplified
    }

    switch subtags.first ?? tag {
    case "en": return .english
    case "ja": return .japanese
    case "fr": return .french
    case "de": return .german
    case "ru": return .russian
    case "vi": return .vietnamese
    case "ko": return .korean
    case "ms": return .malay
    case "it": return .italian
    case "id", "in": return .indonesian
    case "pt": return .portuguese
    case "es": return .spanish
    case "tr": return .turkish
    case "ar": return .arabic
    case "uk": return .ukrainian
    case "nl": return .dutch
    default: return .english
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
