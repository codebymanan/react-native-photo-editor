# Third-party notices

This package bundles code and assets adapted from the project below. Its
license requires the following notice to accompany them.

## PhotoEditor

The Android editor screen is adapted from the sample app of
[PhotoEditor](https://github.com/burhanrashid52/PhotoEditor) by Burhanuddin
Rashid. That covers the classes in `android/src/main/java/com/photoeditor/editor`,
the layouts, drawables and strings in `android/src/main/res`, and the filter
previews in `android/src/main/assets/filters`.

```
MIT License

Copyright (c) 2020 Burhanuddin Rashid

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Dependencies

The editing engines themselves are not bundled. They are fetched at build time
under their own licenses:

- Android: [PhotoEditor](https://github.com/burhanrashid52/PhotoEditor)
  (`com.burhanrashid52:photoeditor`), MIT
- iOS: [ZLImageEditor](https://github.com/longitachi/ZLImageEditor), MIT
