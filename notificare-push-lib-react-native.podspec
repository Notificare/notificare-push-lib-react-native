require "json"

 package = JSON.parse(File.read(File.join(__dir__, "package.json")))

 Pod::Spec.new do |s|
  s.name         = "notificare-push-lib-react-native"
  s.version      = package["version"]
  s.summary      = package['description']
  s.author       = package['author']
  s.homepage     = package['homepage']
  s.license      = package['license']
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/Notificare/notificare-push-lib-react-native.git", :tag => s.version.to_s }
  s.source_files  = "ios/**/*.{h,m}"
  s.dependency "React"
  s.dependency "notificare-push-lib", "2.4-beta2"
end
