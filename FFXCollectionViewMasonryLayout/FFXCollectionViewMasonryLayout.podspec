Pod::Spec.new do |s|
s.name         = "FFXCollectionViewMasonryLayout"
s.version      = "1.0"
s.summary      = "Advanced User Interfaces Using Collection View"
s.description  = <<-DESC
This example demonstrates a UICollectionViewLayout which is able to display fullspan collectionViewCells between masonry
sections.
DESC
s.homepage     = "https://empora.com"
s.license      = { :type => "MIT License", :file => "LICENSE.txt" }
s.authors      = {"Sebastian Boldt" => "sebastian.boldt@empora.com"}
s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/Empora/FFXCollectionViewMasonryLayout.git", :tag => "v{s.version}" }
s.source_files = "FFXCollectionViewMasonryLayout/{Categories,DataSources,Layouts,Views,ViewControllers}/*.{h,m}"
s.framework    = "UIKit"
s.requires_arc = true
end