Pod::Spec.new do |s|
  s.name = 'AUApp'
  s.version = '0.1.0'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.summary = 'A short description of AUApp.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  TODO: Add long description of the pod here.
                       DESC

  s.homepage = 'https://github.com/genedelisa/AUApp'
  s.authors = { 'Gene De Lisa' => 'gene@rockhoppertech.com' }
  s.source = { :git => 'https://github.com/genedelisa/AUApp.git', :tag => s.version }
  s.ios.deployment_target = '11.0'
  s.pod_target_xcconfig =  {
    'SWIFT_VERSION' => '4.0',
  }

  s.source_files = 'AUApp/Classes/**/*'

  s.resource_bundles = {
    'AUApp' => ['AUApp/Assets/*.png']
  }

# if a module
# s.source_files = 'Source/*.{h,m,swift}'
# s.resource_bundles = {
#   'AUApp' => ['Resources/**/*.{png}']
# }

#   s.dependency 'XCGLogger', '~> 6.0.1'

end
