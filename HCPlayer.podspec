#
#  Be sure to run `pod spec lint HCCoren.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "HCPlayer"
  s.version      = "0.2.3"
  s.summary      = "这是一个视频与音频播放器的库。"
  s.description  = <<-DESC
这是一个视频的播放特定的核心库。包含了视频、音频、歌词及缓冲处理的功能。
setPlayerData:...
play
                   DESC

  s.homepage     = "https://github.com/halfking/HCPlayer"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "halfking" => "kimmy.huang@gmail.com" }
  # Or just: s.author    = ""
  # s.authors            = { "" => "" }
  # s.social_media_url   = "http://twitter.com/"

  # s.platform     = :ios
   s.platform     = :ios, "7.0"

#  When using multiple platforms
s.ios.deployment_target = "7.0"
# s.osx.deployment_target = "10.7"
# s.watchos.deployment_target = "2.0"
# s.tvos.deployment_target = "9.0"

s.source       = { :git => "https://github.com/halfking/HCPlayer", :tag => s.version}

s.source_files  = "HCPlayer/**/*.{h,m,mm,c,cpp}","HCPlayer/**/*.bundle"
s.exclude_files = "HCPlayer/HCPlayerTest/**/*"
#s.public_header_files = "HCPlayer/**/*.h"

s.resource  = "HCPlayer.bundle"
# s.resources = "Resources/*.png"
# s.preserve_paths = "FilesToSave", "MoreFilesToSave"
#s.frameworks = "UIKit", "Foundation"

s.libraries = "icucore","stdc++"
s.xcconfig = { "CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" => "YES","ENABLE_BITCODE" => "YES","DEFINES_MODULE" => "YES","HEADER_SEARCH_PATHS" => "$(inherited)","LIBRARY_SEARCH_PATHS" => "$(inherited)" }
s.pod_target_xcconfig = { 'LIBRARY_SEARCH_PATHS' => "$(inherited) " }
# s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }

s.dependency "HCMinizip"
s.dependency "hccoren"
s.dependency "HCBaseSystem"
s.dependency "HCMVManager"
s.dependency "HCAudioUnit"

#s.subspec 'lame' do |spec|
#    spec.source_files = ['Lib/*.h']
#    spec.public_header_files = ['Lib/*.h']
#    spec.preserve_paths = 'Lib/*.h'
#    spec.vendored_libraries = 'Lib/libmp3lame.a', 'Lib/libopencore-amrnb.a','Lib/libopencore-amrwb.a'
#    spec.libraries = 'mp3lame', 'opencore-amrnb','opencore-amrwb'
#    spec.xcconfig = { 'HEADER_SEARCH_PATHS' => "$(inherited) ${PODS_ROOT}/#{s.name}/Lib/**" }
#
#end

end
