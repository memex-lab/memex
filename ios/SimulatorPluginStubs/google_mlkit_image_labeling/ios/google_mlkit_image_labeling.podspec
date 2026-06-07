Pod::Spec.new do |s|
  s.name = 'google_mlkit_image_labeling'
  s.version = '0.14.2'
  s.summary = 'Simulator-only Memex stub for google_mlkit_image_labeling.'
  s.description = 'Keeps the Flutter plugin registration path available without linking Google ML Kit native frameworks on iOS simulators.'
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
