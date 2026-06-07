Pod::Spec.new do |s|
  s.name = 'google_mlkit_commons'
  s.version = '0.11.1'
  s.summary = 'Simulator-only Memex stub for google_mlkit_commons.'
  s.description = 'Registers the Flutter plugin without linking Google ML Kit native frameworks on iOS simulators.'
  s.homepage = 'https://github.com/memex-lab/memex'
  s.license = { :type => 'MIT' }
  s.authors = { 'Memex' => 'memex' }
  s.source = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '15.5'
  s.ios.deployment_target = '15.5'
  s.static_framework = true
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }
end
