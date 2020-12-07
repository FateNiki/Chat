# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
inhibit_all_warnings!

target 'Chat' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Chat
  pod 'Firebase/Firestore'
  pod 'SwiftLint'
end

target 'ChatTests' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ChatTests
  pod 'Firebase/Firestore'
end

target 'ChatUITests' do 
    # Pods for ChatTests
    pod 'Firebase/Firestore'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
