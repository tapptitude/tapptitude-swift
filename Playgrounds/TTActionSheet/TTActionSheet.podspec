Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "TTActionSheet"
s.summary = "ActionSheet that supports multiline message cells"
s.requires_arc = true
s.version = "0.1.0"
s.author = { "Efraim Budusan" => "efraim.budusan@tapptitude.com" }
s.homepage = "www.tapptitude.com"
s.framework = "UIKit"
s.source = { :git => 'https://bitbucket.org/tapptitude/tapptitude-swift.git' }
s.resources    = 'TTActionSheet/*.{xib}'
s.source_files = 'TTActionSheet/*.{swift}'
s.dependency 'Tapptitude'

end