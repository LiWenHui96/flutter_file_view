#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_file_view.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_file_view'
  s.version          = '2.2.1'
  s.summary          = 'A file viewer plugin for Flutter, support local file and network link of Android, iOS.'
  s.description      = <<-DESC
A file viewer plugin for Flutter, support local file and network link of Android, iOS.
                       DESC
  s.homepage         = 'https://github.com/LiWenHui96/flutter_file_view'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'LiWeNHuI' => 'sdgrlwh@163.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
