Pod::Spec.new do |s|
  s.name         = "SSDataSources"
  s.version      = "0.7.3"
  s.summary      = "Flexible data sources for your UITableView and UICollectionView."
  s.homepage     = "https://github.com/splinesoft/SSDataSources"
  s.license      = { :type => 'MIT', :file => 'LICENSE'  }
  s.author       = { "Jonathan Hersh" => "jon@her.sh" }
  s.source       = { :git => "https://github.com/splinesoft/SSDataSources.git", :tag => s.version.to_s }
  s.platform     = :ios, '6.0'
  s.requires_arc = true
  s.source_files = 'SSDataSources/*.{h,m}'
  s.frameworks   = 'UIKit', 'CoreData'
  s.social_media_url = "https://twitter.com/jhersh"
  s.compiler_flags = "-fmodules"
end
