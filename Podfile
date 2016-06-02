platform :ios, '8.0'
use_frameworks!

target 'hacksmiths' do
    pod 'Spring', :git => 'https://github.com/MengTo/Spring.git', :branch => 'swift2', :inhibit_warnings => false
    pod 'Fabric', :inhibit_warnings => false
    pod 'Crashlytics', :inhibit_warnings => false
    pod 'SwiftyButton'
    pod 'SwiftyButton/CustomContent'
    pod 'TextFieldEffects', :inhibit_warnings => true
    pod 'SwiftValidator', '3.0.3'
    pod 'Alamofire', '~> 3.3'
    pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
    pod 'NVActivityIndicatorView', '~> 2.5'
    pod 'PromiseKit'
    pod 'Gloss', '~> 0.7'
    pod 'Timberjack'
    pod 'ChameleonFramework'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        next unless (target.name == 'PromiseKit')
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
        end
    end
end