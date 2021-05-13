

platform :ios, '13.0'

target 'XY' do
  use_frameworks!

  # Pods for XY_APP

  target 'XYTests' do
    inherit! :search_paths
    # Pods for testing
  end
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'Firebase/Functions'
pod 'Firebase/Database'
pod 'Firebase/Messaging'
pod 'Firebase/Crashlytics'
pod 'Firebase/Analytics'
pod 'CodableFirebase'
pod 'FaveButton'
pod 'SwipeCellKit'
pod 'CameraManager', '~> 5.1'
pod 'IQKeyboardManagerSwift'
pod 'ImagePicker'
pod 'Kingfisher', '~> 6.0'
pod 'Hero'
pod 'SwiftyCam'

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end

end
