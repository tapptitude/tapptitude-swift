Pod::Spec.new do |s|
  s.name         = 'Tapptitude'
  s.version      = '2.2'
  s.summary      = 'A library to speed up development.'
  s.author       = { 'Alexandru Tudose' => 'alextud@gmail.com' }
  s.homepage     = 'http://tapptitude.com/'
  s.platform     = :ios, '8.0'
  s.source       = { :git => 'https://bitbucket.org/tapptitude/tapptitude-swift.git' }
  s.source_files = 'Tapptitude/*.{swift}', 'Tapptitude/Helpers/*.{swift}'
  s.resources    = 'Tapptitude/*.{xib}'
  s.header_mappings_dir = ''
  s.frameworks   = 'UIKit'

  s.prepare_command = './"Xcode Templates/install.sh"'
end
