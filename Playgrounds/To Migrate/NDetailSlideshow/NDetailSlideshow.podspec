Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "NDetailSlideshow"
s.summary = "Nice slideshow i guess(to Do)"
s.requires_arc = true
s.version = "0.1.0"
s.author = { "Ion Toderasco" => "ion.toderasco@tapptitude.com" }
s.homepage = "www.tapptitude.com"
s.framework = "UIKit"
s.source = { :git => 'https://bitbucket.org/tapptitude/tapptitude-swift.git' }
s.resources    = 'NDetailSlideshow/*.{xib}'
s.source_files = 'NDetailSlideshow/*.{swift}'
s.dependency 'Tapptitude'

end