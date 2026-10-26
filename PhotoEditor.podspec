require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

# ZLImageEditor 4.x references iOS 27.1 SDK symbols, so it only compiles on
# Xcode 27.1+, while 3.x builds on older Xcode. Pick the newest line the
# installed Xcode can build, unless the app sets
# PHOTO_EDITOR_ZLIMAGEEDITOR_VERSION in its Podfile to choose explicitly.
zl_image_editor_version = ENV["PHOTO_EDITOR_ZLIMAGEEDITOR_VERSION"].to_s.strip
if zl_image_editor_version.empty?
  xcode_version = `xcodebuild -version 2>/dev/null`[/^Xcode (\d+(?:\.\d+)*)/, 1]
  zl_image_editor_version =
    xcode_version && Gem::Version.new(xcode_version) >= Gem::Version.new("27.1") ? "4.0" : "3.0"
elsif zl_image_editor_version !~ /\A\d+(\.\d+)*\z/
  raise "PHOTO_EDITOR_ZLIMAGEEDITOR_VERSION must be a version such as '3.0' or '4.0', " \
        "got '#{zl_image_editor_version}'"
end

Pod::Spec.new do |s|
  s.name         = "PhotoEditor"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/codebymanan/react-native-photo-editor.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift,cpp}"
  s.private_header_files = "ios/**/*.h"
  s.swift_version = "5.0"

  s.frameworks = "Photos"
  s.dependency "ZLImageEditor", "~> #{zl_image_editor_version}"

  install_modules_dependencies(s)
end
