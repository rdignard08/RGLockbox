Pod::Spec.new do |s|
  s.name     = 'RGLockbox'
  s.version  = '1.0.0'
  s.license  = 'BSD'
  s.summary  = 'A simpler & faster keychain interface'
  s.homepage = 'https://github.com/rdignard08/RGLockbox'
  
  s.authors  = { "Ryan Dignard" => "conceptuallyflawed@gmail.com" }
  s.source   = { :git => "https://github.com/rdignard08/RGLockbox.git", :tag => s.version }
  s.requires_arc = true

  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.public_header_files = 'RGLockbox/*.h'
  s.source_files = 'RGLockbox'

  s.frameworks = 'Security'
end
