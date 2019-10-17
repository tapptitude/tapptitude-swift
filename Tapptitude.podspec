Pod::Spec.new do |s|
  s.name         = 'Tapptitude'
  s.version      = '3.0'
  s.summary      = 'A library to speed up development.'
  
  s.homepage     = 'https://tapptitude.com'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Alexandru Tudose' => 'alextud@gmail.com' }

  s.platform     = :ios, '11.0'
  s.ios.deployment_target = "11.0"
  s.swift_version = "5.0"

  s.source       = { :git => 'https://bitbucket.org/tapptitude/tapptitude-swift.git' }
  s.source_files = 'Tapptitude/*.{swift}', 'Tapptitude/Helpers/*.{swift}'
  
  s.header_mappings_dir = ''
  s.resources    = 'Tapptitude/*.{xib}'
  s.frameworks   = 'UIKit'

  s.prepare_command = './"Xcode Templates/install.sh"'
end
