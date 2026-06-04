#
# FFI plugin registration for macOS. The Rust library is not built here;
# it is downloaded by hook/build.dart or tool/install.dart.
#
Pod::Spec.new do |s|
  s.name             = 'office_oxide_ffi'
  # CocoaPods does not accept '+' build metadata; 0.1.2.1 ↔ pub 0.1.2+1.
  s.version          = '0.1.2.1'
  s.summary          = 'Dart/Flutter FFI for office_oxide document extraction.'
  s.description      = <<-DESC
  Flutter FFI plugin for office_oxide (Word/Excel/PowerPoint extraction).
                       DESC
  s.homepage         = 'https://github.com/SuiltaPico/office_oxide'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'office_oxide contributors' => 'https://github.com/SuiltaPico/office_oxide' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.13'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
