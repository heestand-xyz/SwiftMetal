Pod::Spec.new do |spec|

  spec.name         = "SwiftMetal"
  spec.version      = "0.1.0"

  spec.summary      = "Write Metal in Swift"
  spec.description  = <<-DESC
  					          Write Metal in Swift
                      Auto generated Metal code
                      DESC

  spec.homepage     = "http://hexagons.se"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Hexagons" => "anton@hexagons.se" }
  spec.social_media_url   = "https://twitter.com/anton_hexagons"

  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "10.15"
  spec.tvos.deployment_target = "13.0"

  spec.swift_version = '5.0'

  spec.source       = { :git => "https://github.com/hexagons/SwiftMetal.git", :branch => "master", :tag => "#{spec.version}" }

  spec.source_files  = "Sources", "Sources/**/*.swift"

end
