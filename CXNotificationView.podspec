#
# Be sure to run `pod lib lint CXNotificationView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do | s |
    s.name             = 'CXNotificationView'
    s.version          = '1.0'
    s.summary          = 'CXNotificationView'

    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!

    s.description      = 'CXNotificationView'
    
    s.homepage         = 'https://github.com/ishaolin/CXNotificationView'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'wshaolin' => 'ishaolin@163.com' }
    s.source           = { :git => 'https://github.com/ishaolin/CXNotificationView.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '9.0'
    
    s.public_header_files = 'CXNotificationView/Classes/**/*.h'
    s.source_files = 'CXNotificationView/Classes/**/*'

    s.dependency 'CXFoundation'
    s.dependency 'CXUIKit'
end
