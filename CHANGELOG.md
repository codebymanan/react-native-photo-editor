# Changelog

## 1.0.1 - 2026-10-26

The first stable release. There is no 1.0.0: that number was used by an
early build that was later unpublished, and npm never reuses a version.

### Fixed

- Android: on Android 15 and later with 3-button navigation, the navigation bar
  covered the close and save buttons, so edits could not be saved. The editor
  now pads itself clear of the system bars.
- Android: on Android 16 and later, in apps targeting API 36, the back button
  or gesture closed the editor and discarded edits without asking. It now shows
  the same save prompt as the close button.
- Android: switching dark mode, changing the font size, rotating a large screen
  or resizing the window recreated the editor, losing every edit, and crashed
  the app if the shape sheet was open. The editor now handles these changes in
  place.
- Android: the text tool did not open the keyboard on recent Android versions,
  leaving an empty dark screen until the user tapped it, and the keyboard then
  covered the color picker. The keyboard now opens right away and the colors
  stay above it.

### Changed

- Android: the sticker tool is hidden when `stickers` is empty, as on iOS. The
  built-in sample stickers, which were loaded from Flaticon's servers, are gone.
- The npm package shrinks from 6.3 MB to about 0.6 MB, most of which ended up
  in every Android app. Two unused fonts and an unused image are removed, and
  the filter previews are recompressed.
- The `react-native` peer dependency is now `>=0.76.0`, since the library
  needs the New Architecture.

### Docs

- README: installation steps for iOS pods, rebuilding and Expo, requirements,
  a feature table, and details on the returned file.
- Added `THIRD_PARTY_NOTICES.md` crediting the PhotoEditor sample app that the
  Android editor screen is adapted from.

## 0.2.1 - 2026-10-26

- iOS: `pod install` picks ZLImageEditor 4.x on Xcode 27.1 or newer and 3.x on
  older Xcode. Set `PHOTO_EDITOR_ZLIMAGEEDITOR_VERSION` to choose explicitly.

## 0.2.0 - 2026-10-26

- Android: PhotoEditor 3.1.1. Undo and redo grey out when there is nothing to
  undo or redo.
- iOS: ZLImageEditor 4.x.
- iOS: a sticker picker for the `stickers` option, and support for `ph://`
  photo library URIs.
- iOS: `open()` rejects with `E_IN_PROGRESS` while another editor is open.
- Jest mock at `@codebymanan/react-native-photo-editor/jest/mock`.

## 0.1.0 - 0.1.2 - 2026-08-21

First releases under the `@codebymanan` scope.

- `open()` with `path` and `stickers`.
- `language` and `translations` options, with right-to-left support on Android.
- 0.1.2 fixed the Android build on React Native 0.87.
