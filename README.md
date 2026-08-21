# react-native-photo-editor

A React Native photo editor plugin wrapping native editors for Android and iOS.

## Installation

```sh
npm install react-native-photo-editor
```

## Usage

```js
import { open } from 'react-native-photo-editor';

const editedPath = await open({
  path: 'https://example.com/photo.jpg',
  stickers: ['https://example.com/sticker.png'],
});
```

`open()` resolves with the file path of the edited image, or rejects with
`E_CANCELLED` if the user backs out.

| Option | Type | Description |
| --- | --- | --- |
| `path` | `string` | **Required.** Image to edit. Accepts a local file path, a `file://` or `content://` URI, or a remote `http(s)` URL. |
| `stickers` | `string[]` | Sticker image URLs shown in the sticker picker. |
| `language` | `string` | BCP-47 tag (`'fr'`, `'pt-BR'`, `'zh-Hans'`) for the editor UI. Defaults to the device language. See [Localization](#localization). |
| `translations` | `Record<string, string>` | Per-key string overrides. See [Localization](#localization). |

## Localization

By default the editor follows the device language on both platforms. Pass
`language` only when your app has its own language picker and the editor should
follow that instead:

```js
await open({ path, language: 'fr' });
```

### iOS

The iOS editor already ships 18 languages and follows the device locale with no
setup. Nothing to configure.

`language` maps onto those 18: Chinese (Simplified and Traditional), English,
Japanese, French, German, Russian, Vietnamese, Korean, Malay, Italian,
Indonesian, Portuguese, Spanish, Turkish, Arabic, Ukrainian and Dutch. A tag
outside that set falls back to English rather than to the device language,
since the caller has explicitly asked not to use the device setting.

### Android

The Android editor ships English only, but every user-facing string is a normal
Android string resource, so **your app can translate it without forking this
library**.

Add a `values-<language>` folder to your own app and redefine the keys you care
about. Android's resource merger gives your app priority over library
resources, so your values win:

```xml
<!-- android/app/src/main/res/values-fr/strings.xml -->
<resources>
    <string name="pe_label_brush">Pinceau</string>
    <string name="pe_label_save">Enregistrer</string>
    <string name="pe_msg_saving">Enregistrement…</string>
</resources>
```

That's the whole mechanism. Three things worth knowing:

- **Override only what you need.** Keys you leave out fall back to this
  library's English.
- **Any language works**, including ones this library has never heard of. The
  key names are the only contract.
- **Match the qualifier.** Overriding a key in the default `values/` folder does
  *not* win against a more specific match. Put French overrides in
  `values-fr/`, German in `values-de/`, and so on.
- **`language` selects the folder, it does not create one.** Passing
  `language: 'fr'` makes the editor resolve strings against `values-fr/`; if
  your app has no `values-fr/`, the editor stays in English. The example app
  ships one to demonstrate this.

### Supplying strings from JS

`translations` overrides individual strings by key, for when your copy lives in
JS rather than in native resources, or when you need a language iOS does not
ship:

```js
await open({
  path,
  language: 'sv',
  translations: {
    pe_label_save: 'Spara',
    pe_label_cancel: 'Avbryt',
    pe_msg_saving: 'Sparar…',
  },
});
```

Keys you leave out keep their built-in value, and on Android a `values-<lang>`
folder still applies underneath, so the two mechanisms stack: resources for the
bulk, `translations` for whatever you want to override per call.

**Android honours every key below. iOS honours nine of them** — the only strings
the underlying editor exposes — and ignores the rest. That asymmetry is the
reason to reach for a `values-<lang>` folder first on Android and treat
`translations` as the cross-platform layer on top.

#### String keys

| Key | English | iOS |
| --- | --- | --- |
| `pe_app_name` | Photo Editor | |
| `pe_label_brush` | Brush | |
| `pe_label_shape` | Shape | |
| `pe_label_oval` | Oval | |
| `pe_label_rectangle` | Rectangle | |
| `pe_label_line` | Line | |
| `pe_label_arrow` | Arrow | |
| `pe_label_emoji` | Emoji | |
| `pe_label_sticker` | Sticker | |
| `pe_label_eraser` | Eraser | |
| `pe_label_eraser_mode` | Eraser Mode | |
| `pe_label_text` | Text | |
| `pe_label_filter` | Filter | |
| `pe_label_adjust` | Adjust | |
| `pe_label_opacity` | Opacity | |
| `pe_label_rotation` | Rotation | |
| `pe_label_undo` | Undo | ✓ |
| `pe_label_redo` | Redo | |
| `pe_label_close` | Close | | |
| `pe_label_done` | Done | ✓ |
| `pe_label_save` | Save | ✓ |
| `pe_label_cancel` | Cancel | ✓ |
| `pe_label_discard` | Discard | |
| `pe_msg_save_image` | Do you want to exit without saving the image? | |
| `pe_msg_saving` | Saving… | ✓ |
| `pe_msg_save_failed` | Failed to save image | |
| `pe_msg_drag_to_remove` | *(iOS only)* Drag here to remove | ✓ |
| `pe_filter_none` | None | |
| `pe_filter_auto_fix` | Auto Fix | |
| `pe_filter_brightness` | Brightness | ✓ |
| `pe_filter_contrast` | Contrast | ✓ |
| `pe_filter_documentary` | Documentary | |
| `pe_filter_duo_tone` | Duo Tone | |
| `pe_filter_fill_light` | Fill Light | |
| `pe_filter_fish_eye` | Fish Eye | |
| `pe_filter_grain` | Grain | |
| `pe_filter_gray_scale` | Grayscale | |
| `pe_filter_lomish` | Lomish | |
| `pe_filter_negative` | Negative | |
| `pe_filter_posterize` | Posterize | |
| `pe_filter_saturate` | Saturate | ✓ |
| `pe_filter_sepia` | Sepia | |
| `pe_filter_sharpen` | Sharpen | |
| `pe_filter_temperature` | Temperature | |
| `pe_filter_tint` | Tint | |
| `pe_filter_vignette` | Vignette | |
| `pe_filter_cross_process` | Cross Process | |
| `pe_filter_black_white` | Black & White | |
| `pe_filter_flip_horizontal` | Flip Horizontal | |
| `pe_filter_flip_vertical` | Flip Vertical | |
| `pe_filter_rotate` | Rotate | |

## Contributing

- [Development workflow](CONTRIBUTING.md#development-workflow)
- [Sending a pull request](CONTRIBUTING.md#sending-a-pull-request)
- [Code of conduct](CODE_OF_CONDUCT.md)

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
