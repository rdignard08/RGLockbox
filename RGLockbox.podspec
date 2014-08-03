Pod::Spec.new do |s|
  s.name     = 'RGLockbox'
  s.version  = '0.0.1'
  s.license  = 'BSD'
  s.summary  = 'A simpler interface to iOS keychain access.'
  s.homepage = 'https://github.com/rdignard08/RGLockbox'
  s.author   = { "Ryan Dignard" => "dignard@1debit.com" }
  s.source   = { :git => "http://github.com/rdignard08.git", :tag => s.version.to_s }
  s.platform = :ios
  s.source_files = 'RGLockbox'
  s.frameworks = 'Security'
  s.requires_arc = true
end
