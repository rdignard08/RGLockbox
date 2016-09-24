Pod::Spec.new do |s|
  s.name     = 'RGSwiftKeychain'
  s.version  = '2.3.4'
  s.license  = 'BSD'
  s.summary  = 'A simpler & faster keychain interface written in Swift'
  s.homepage = 'https://github.com/rdignard08/RGLockbox/'
  
  s.authors  = { "Ryan Dignard" => "conceptuallyflawed@gmail.com" }
  s.source   = { :git => "https://github.com/rdignard08/RGLockbox.git", :tag => s.version }
  s.requires_arc = true
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0', 'CODE_SIGNING_REQUIRED' => 'NO', 'CODE_SIGN_IDENTITY' => '', 'CODE_SIGNING_ALLOWED' => 'NO' }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'RGLockbox'

  s.frameworks = 'Security'
end
