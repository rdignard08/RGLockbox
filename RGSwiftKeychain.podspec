Pod::Spec.new do |s|
  s.name     = 'RGSwiftKeychain'
  s.version  = '2.2.0'
  s.license  = 'BSD'
  s.summary  = 'A simpler & faster keychain interface written in Swift'
  s.homepage = 'https://github.com/rdignard08/RGLockbox/'
  
  s.authors  = { "Ryan Dignard" => "conceptuallyflawed@gmail.com" }
  s.source   = { :git => "https://github.com/rdignard08/RGLockbox.git", :tag => s.version }
  s.requires_arc = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'RGLockbox'

  s.frameworks = 'Security'
end
