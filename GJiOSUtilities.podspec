Pod::Spec.new do |s|
  s.name             = "GJiOSUtilities"
  s.version          = "0.0.4"
  s.summary          = "GravityJack iOS utility class."
  s.description      = <<-DESC
                       Initial compilation of frequently used methods when developing iOS applications.
                       DESC
  s.homepage         = "https://github.com/GravityJack/iOSUtilities"
  s.license          = 'MIT'
  s.author           = { "Brad Flegel" => "brad@gravityjack.com" }
  s.source           = { :git => "https://github.com/GravityJack/iOSUtilities.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'GJiOSUtilities' => ['Pod/Assets/*.png']
  }

  s.frameworks = 'UIKit'

end
