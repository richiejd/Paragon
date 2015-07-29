#
# Be sure to run `pod lib lint Paragon.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Paragon"
  s.version          = "0.1.0"
  s.summary          = "Paragon provides model mapping and a networking layer."
  s.description      = <<-DESC
Paragon have two primary components currently: a series of mapping classes and networking classes. The mapping classes allow you to easily map model classes to and from dictionaries (and therefore json). The networing classes provide an easy mechanism for setting up endpoints that you can easily use in your application. By design you will set the networking manager to have default settings for your network requests but each endpoint can be uniquely defined and then used in your api client which should be the primary class your view controllers and otehr network-interacting components talk to.

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/Javier27/Paragon"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Richie" => "richiejdavis27@gmail.com" }
  s.source           = { :git => "https://github.com/Javier27/Paragon.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Paragon' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 2.3'
end
