Pod::Spec.new do |s|
  s.name         = "SmashKit"
  s.version      = "0.0.1"
  s.summary      = "A Framework for laying out view controllers."
  s.homepage     = "https://github.com/gillygize/SmashKit"
  s.license      = { :type => 'BSD', :file => 'LICENSE' }
  s.author       = { "Matthew Gillingham" => "gillygize@gmail.com.com" }
  s.source       = { :git => "https://github.com/gillygize/SmashKit.git" }
  s.platform     = :ios, '5.0'
  s.source_files = 'SmashKit', 'SmashKit/**/*.{h,m}'
  s.requires_arc = true
  s.framework    = 'UIKit'
end
