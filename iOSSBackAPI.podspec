#
# Be sure to run `pod lib lint iOSSBackAPI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iOSSBackAPI'
  s.version          = '0.1.0'
  s.summary          = "It is a API to communicate with Shop Back Technology's services. This API reads the user position and send a notification in background."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: It is a API to communicate with Shop Back Technology's services. This API reads the user position and send a notification in background.
                       DESC

  s.homepage         = 'https://github.com/MatheusRR/iOSSBackAPI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Matheus Ribeiro' => 'empresas.mr.two@gmail.com' }
  s.source           = { :git => 'https://github.com/MatheusRR/iOSSBackAPI.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.3'

  s.source_files = 'iOSSBackAPI/Classes/**/*'
  
  # s.resource_bundles = {
  #   'iOSSBackAPI' => ['iOSSBackAPI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit'
    s.dependency 'Alamofire', '~> 4.4'
end
