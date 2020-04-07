# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

target 'UnitTestWorkshop' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for UnitTestWorkshop
  pod 'RxSwift', '~> 4.1.2'
  pod 'RxCocoa', '~> 4.1.2'
  pod 'RxOptional', '~> 3.5.0'
    
  target 'UnitTestWorkshopTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxTest', '~> 4.1.2'
    pod 'Quick', '~> 1.3.1'
  end

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
            config.build_settings['SWIFT_VERSION'] = '4.0'
            config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
        end
    end
end
