import UIKit
import ZLImageEditor

/// Bottom sheet listing the `stickers` passed to `open()`.
///
/// ZLImageEditor only offers its image sticker tool when a view conforming to
/// `ZLImageStickerContainerDelegate` is configured, and leaves showing, hiding
/// and populating it entirely to that view.
final class StickerContainerView: UIView, ZLImageStickerContainerDelegate {

  var selectImageBlock: ((UIImage) -> Void)?
  var hideBlock: (() -> Void)?

  private static let sheetHeightRatio: CGFloat = 0.45
  private static let cellSpacing: CGFloat = 12
  private static let columns: CGFloat = 4

  private let urls: [String]
  /// Indexed like `urls`; nil until that sticker has loaded, and stays nil if it fails.
  private var images: [UIImage?]

  private let sheet = UIView()
  private let collectionView: UICollectionView

  init(urls: [String]) {
    self.urls = urls
    self.images = Array(repeating: nil, count: urls.count)

    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = Self.cellSpacing
    layout.minimumLineSpacing = Self.cellSpacing
    layout.sectionInset = UIEdgeInsets(
      top: Self.cellSpacing, left: Self.cellSpacing, bottom: Self.cellSpacing, right: Self.cellSpacing)
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    super.init(frame: .zero)

    // Tapping the dimmed area above the sheet dismisses it; the editor does not.
    let dismissTap = UITapGestureRecognizer(target: self, action: #selector(hide))
    dismissTap.delegate = self
    addGestureRecognizer(dismissTap)

    sheet.backgroundColor = UIColor(white: 0.1, alpha: 0.95)
    sheet.layer.cornerRadius = 12
    sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    addSubview(sheet)

    collectionView.backgroundColor = .clear
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(StickerCell.self, forCellWithReuseIdentifier: StickerCell.reuseIdentifier)
    sheet.addSubview(collectionView)

    loadStickers()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - ZLImageStickerContainerDelegate

  func show(in view: UIView) {
    if superview !== view {
      removeFromSuperview()
      view.addSubview(self)
    }
    frame = view.bounds
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
    isHidden = false
    layoutIfNeeded()

    sheet.transform = CGAffineTransform(translationX: 0, y: sheet.bounds.height)
    backgroundColor = .clear
    UIView.animate(withDuration: 0.25) {
      self.sheet.transform = .identity
      self.backgroundColor = UIColor(white: 0, alpha: 0.3)
    }
  }

  @objc private func hide() {
    UIView.animate(withDuration: 0.25, animations: {
      self.sheet.transform = CGAffineTransform(translationX: 0, y: self.sheet.bounds.height)
      self.backgroundColor = .clear
    }, completion: { _ in
      self.isHidden = true
      self.sheet.transform = .identity
    })
    hideBlock?()
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()
    let height = bounds.height * Self.sheetHeightRatio
    sheet.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
    collectionView.frame = sheet.bounds
    collectionView.contentInset.bottom = safeAreaInsets.bottom
  }

  // MARK: - Loading

  private func loadStickers() {
    for (index, url) in urls.enumerated() {
      PhotoEditorManager.loadImage(url) { [weak self] result in
        guard case .success(let image) = result else { return }
        DispatchQueue.main.async {
          guard let self else { return }
          self.images[index] = image
          self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
      }
    }
  }
}

extension StickerContainerView: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    !sheet.frame.contains(touch.location(in: self))
  }
}

extension StickerContainerView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    urls.count
  }

  func collectionView(
    _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: StickerCell.reuseIdentifier, for: indexPath) as! StickerCell
    cell.imageView.image = images[indexPath.item]
    return cell
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let gaps = Self.cellSpacing * (Self.columns + 1)
    let side = floor((collectionView.bounds.width - gaps) / Self.columns)
    return CGSize(width: side, height: side)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // A sticker that has not loaded (or failed to) has nothing to add.
    guard let image = images[indexPath.item] else { return }
    selectImageBlock?(image)
    hide()
  }
}

private final class StickerCell: UICollectionViewCell {
  static let reuseIdentifier = "StickerCell"

  let imageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    imageView.contentMode = .scaleAspectFit
    imageView.frame = contentView.bounds
    imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    contentView.addSubview(imageView)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }
}
