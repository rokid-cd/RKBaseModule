#
# Be sure to run `pod lib lint RKBaseModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RKBaseModule'
  s.version          = '0.1.0'
  s.summary          = 'A short description of RKBaseModule.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/刘爽/RKBaseModule'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '刘爽' => 'shuang.liu@rokid.com' }
  s.source           = { :git => 'https://github.com/刘爽/RKBaseModule.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.static_framework = true
  
  s.swift_version = '5.0'

  s.ios.deployment_target = '11.0'
  
  s.default_subspec = 'RKExtention'
  
  s.resources = 'RKBaseModule/Assets/RKBaseModule.bundle'
    
  s.subspec 'RKFilePreview' do |ss|
    ss.source_files = 'RKBaseModule/Classes/RKFilePreview/**/*'
    ss.dependency 'RKBaseModule/RKExtention'
    ss.dependency 'RKBaseModule/RKHUD'
    
    ss.dependency 'KSYMediaPlayer_iOS/KSYMediaPlayer_vod', '~> 3.0.3'
    ss.dependency 'SnapKit', '~> 4.2.0'
    ss.dependency 'Kingfisher'
  end
  
  s.subspec 'RKHUD' do |ss|
    ss.source_files = 'RKBaseModule/Classes/RKHUD/**/*'
  end
  
  s.subspec 'RKExtention' do |ss|
    ss.source_files = 'RKBaseModule/Classes/RKExtention/**/*'
  end
  
  s.subspec 'RKReplayKit' do |ss|
    ss.vendored_frameworks = 'RKBaseModule/Classes/RKReplayKit/RokidReplayKit.framework'
  end
  
end
