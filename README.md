# Hacksmiths App

## Getting Started
This app utilizes Cocoapods to load a number of framework dependencies.
Follow the steps below to install the CocoaPods dependencies.

To install cocopods, run the following command.
```
gem install cocoapods
```

### Installing
With cocopods installed, run the following from the root directory to install the dependencies
```
pod install
```

If this does not work, follow the steps located below in Troubleshooting.

Once installed, open the hacksmiths.xcworkspace file, select your device and build the project.  
NOTE: opening the .xcodeproj file will NOT work because it will not load the Cocoapod dependencies.
## Built With
- XCode
- Swift
- Cocoapods

## Authors

* **Ryan Collins**

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

<div>Icon made by <a href="http://www.icomoon.io" title="Icomoon">Icomoon</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a> is licensed under <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>

### Troubleshooting
If for some reason, you run into issues installing, it's likely due to cocoapods.  What cocoapods does is it manages package dependencies for the project.  You need to make sure that you upen the .xcworkspace project because that is a requirement of cocoapods.

If you still have difficulties, please see the [CocoaPods troubleshooting guide](https://guides.cocoapods.org/using/troubleshooting.html)
