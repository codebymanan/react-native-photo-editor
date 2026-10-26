import Photos
import UIKit
import ZLImageEditor

@objc(PhotoEditorManager)
public class PhotoEditorManager: NSObject {

  @objc public static func open(
    _ path: String,
    stickers: [String],
    language: String?,
    translations: [String: Any]?,
    resolve: @escaping (String) -> Void,
    reject: @escaping (String, String) -> Void
  ) {
    loadImage(path) { result in
      DispatchQueue.main.async {
        let image: UIImage
        switch result {
        case .success(let loaded):
          image = loaded
        case .failure(let error):
          reject("E_FAILED", error.message)
          return
        }
        guard let presenter = topViewController() else {
          reject("E_NO_ACTIVITY", "No view controller available to present the editor")
          return
        }

        ZLImageEditorUIConfiguration.default()
          .languageType(languageType(for: language))
          .customLanguageConfig(customLanguage(from: translations))

        // Assigned on every call, nil included: the configuration is a shared
        // singleton, and the editor hides the sticker tool when this is nil.
        ZLImageEditorConfiguration.default()
          .editImageTools([.draw, .clip, .imageSticker, .textSticker, .mosaic, .filter, .adjust])
          .adjustTools([.brightness, .contrast, .saturation])
          .imageStickerContainerView(stickers.isEmpty ? nil : StickerContainerView(urls: stickers))

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

  /// The editor exposes exactly these nine strings for overriding, so this is
  /// the whole of what `translations` can reach on iOS. Keys are the same ones
  /// Android uses, which is what lets one map drive both platforms.
  private static let overridableKeys: [String: ZLLocalLanguageKey] = [
    "pe_label_cancel": .cancel,
    "pe_label_done": .done,
    "pe_label_save": .editFinish,
    "pe_label_undo": .revert,
    "pe_filter_brightness": .brightness,
    "pe_filter_contrast": .contrast,
    "pe_filter_saturate": .saturation,
    "pe_msg_drag_to_remove": .textStickerRemoveTips,
    "pe_msg_saving": .hudProcessing,
  ]

  /// Always returns a dictionary, empty included: the configuration is a shared
  /// singleton, so anything left unassigned would outlive the call that set it.
  private static func customLanguage(from translations: [String: Any]?) -> [ZLLocalLanguageKey: String] {
    guard let translations else { return [:] }

    return overridableKeys.reduce(into: [:]) { config, entry in
      // Non-string values are dropped rather than coerced, so a mistyped entry
      // falls back to the built-in string.
      if let value = translations[entry.key] as? String, !value.isEmpty {
        config[entry.value] = value
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

  struct LoadError: Error {
    let message: String
  }

  /// Loads the editor image or a sticker. `completion` may run on any queue.
  static func loadImage(_ path: String, completion: @escaping (Result<UIImage, LoadError>) -> Void) {
    let failed = LoadError(message: "Could not load image: \(path)")

    if path.hasPrefix("ph://") {
      loadPhotoLibraryImage(localIdentifier: String(path.dropFirst(5)), path: path, completion: completion)
    } else if path.hasPrefix("http://") || path.hasPrefix("https://") {
      guard let url = URL(string: path) else {
        completion(.failure(failed))
        return
      }
      URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let image = data.flatMap(UIImage.init(data:)) else {
          completion(.failure(failed))
          return
        }
        completion(.success(image))
      }.resume()
    } else {
      let filePath = path.hasPrefix("file://") ? String(path.dropFirst(7)) : path
      guard let image = UIImage(contentsOfFile: filePath) else {
        completion(.failure(failed))
        return
      }
      completion(.success(image))
    }
  }

  /// Resolves a `ph://` URI, as returned by photo pickers such as
  /// @react-native-camera-roll/camera-roll, through the Photos framework.
  private static func loadPhotoLibraryImage(
    localIdentifier: String,
    path: String,
    completion: @escaping (Result<UIImage, LoadError>) -> Void
  ) {
    withPhotoLibraryAccess { granted in
      guard granted else {
        completion(.failure(LoadError(
          message: "Photo library access is needed to load \(path)")))
        return
      }

      // Some pickers hand out only the asset UUID, without the "/L0/001"
      // suffix that a full local identifier carries; try both.
      var identifiers = [localIdentifier]
      if !localIdentifier.contains("/") {
        identifiers.append("\(localIdentifier)/L0/001")
      }
      guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil).firstObject
      else {
        completion(.failure(LoadError(message: "No photo library asset found for \(path)")))
        return
      }

      let options = PHImageRequestOptions()
      // Lets iCloud-only photos download instead of failing.
      options.isNetworkAccessAllowed = true
      options.deliveryMode = .highQualityFormat
      options.version = .current

      PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) {
        data, _, _, _ in
        guard let image = data.flatMap(UIImage.init(data:)) else {
          completion(.failure(LoadError(message: "Could not load image: \(path)")))
          return
        }
        completion(.success(image))
      }
    }
  }

  /// Only prompts when the user has never been asked. Limited access counts as
  /// granted: the asset is reachable if the user included it in the selection.
  private static func withPhotoLibraryAccess(_ completion: @escaping (Bool) -> Void) {
    switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
    case .authorized, .limited:
      completion(true)
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
        completion(status == .authorized || status == .limited)
      }
    default:
      completion(false)
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
