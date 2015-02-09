Pod::Spec.new do |s|
s.name         = 'FFXCollectionViewMasonryLayout'
s.version      = '1.0'
s.summary      = 'UICollectionView Masonry Layout'
s.author = {
'Lars Anderson' => 'sebastian.boldt@empora.com'
}
s.source = {
:git => 'https://github.com/Empora/FFXCollectionViewMasonryLayout.git'
}
s.source_files = 'Source/*.{h,m}'
s.dependency     'UIKit'
end