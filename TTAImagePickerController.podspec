#
# Be sure to run `pod lib lint TTAImagePickerController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTAImagePickerController'
  s.version          = '0.2.0'
  s.summary          = 'A Lightweight image selection framework/一个轻量级图片选择框架'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A Lightweight image selection framework
* A Lightweight image selection framework, Low memory consumption
* Support Device orientation and iPad
* Almost identical to the `UIImagePickerController` interface, easy to get started
* Convenient preview function
* A lot of small details

一个轻量级图片选择框架
* 个轻量级图片选择框架,内存占用低
* 适配屏幕旋转和 iPad
*  与 `UIImagePickerController` 相似的接口, 容易上手使用
* 便捷胡图片预览功能
* 许多小细节
                       DESC

  s.homepage         = 'https://github.com/TMTBO/TTAImagePickerController'
  # s.screenshots     = 'https://github.com/TMTBO/TTAImagePickerController/blob/master/TTAImagePicker_all.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'TobyoTenma' => 'tmtbo@hotmail.com' }
  s.source           = { :git => 'https://github.com/TMTBO/TTAImagePickerController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'TTAImagePickerController/Classes/**/*'
  
  s.resource_bundles = {
    'TTAImagePickerController' => ['TTAImagePickerController/Assets/*.png', 'TTAImagePickerController/Resources/*.ttf', 'TTAImagePickerController/Resources/*.lproj']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'Photos', 'AVFoundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
