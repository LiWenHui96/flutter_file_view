#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_file_view.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_file_view'
  s.version          = '1.2.1'
  s.summary          = 'File viewer plugin for Flutter, support local file and network link of Android, iOS'
  s.description      = <<-DESC
File viewer plugin for Flutter, support local file and network link of Android, iOS
                       DESC
  s.homepage         = 'https://github.com/LiWenHui96/flutter_file_view'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'LiWeNHuI' => 'sdgrlwh@163.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.ios.deployment_target = '8.0'

  # 引入系统 framework
  # s.frameworks = 'QuickLook'

  s.swift_version = '5.0'
end
