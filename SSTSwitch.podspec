#
# Be sure to run `pod lib lint SlidingNumberView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'SSTSwitch'
s.version          = '0.0.1'
s.summary          = 'SSTSwitch contains multiple types of switches to use easily'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = 'SSTSwitch is a collection of multiple switches that are customizable'

s.homepage         = 'https://github.com/bupstan/SSTSwitch'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'bupstan' => 'bupstan.dev@gmail.com' }
s.source           = { :git => 'https://github.com/bupstan/SSTSwitch.git', :tag => s.version.to_s }

s.ios.deployment_target = '10.0'
s.swift_version = '4.2'
s.source_files = 'SSTSwitch/Classes/**/*'

end
