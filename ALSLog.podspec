#
# Be sure to run `pod lib lint ALSLog.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ALSLog'
  s.version          = '0.0.3'
  s.summary          = 'ios log'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
 ios 日志，可以生成本地日志，也可以生成网络日志，同时可以捕获异常，并投递到sentry服务器。
                       DESC

  s.homepage         = 'https://github.com/yangzmpang/ALSLog'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yangzmpang' => 'zimin.yzm@alibaba-inc.com' }
  s.source           = { :git => 'https://github.com/yangzmpang/ALSLog.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'ALSLog/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ALSLog' => ['ALSLog/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
s.dependency 'CocoaLumberjack','3.2.1'
s.dependency 'Sentry', '3.8.1'
end
