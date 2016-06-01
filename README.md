![Hacksmiths Logo](https://rawgit.com/teamhacksmiths/food-drivr-backend/master/.github/assets/hacksmiths-logo.png)

# Hackmiths Mobile App - Made with ❤️ by Ryan Collins - Founder of [Hacksmith.io](http://hacksmiths.io)
Hacksmiths was built to provide a platform for Udacity students to collaborate on meaningful projects for social good.  Our debut project, the [Food Drivr App](https://github.com/teamhacksmiths/food-drivr), a web and mobile application designed to make the process of donating edible food, is nearing public release as of late May 2016.

The Hacksmiths.io website and ios mobile application serve to make it simple for people to learn about the work that we are doing.  It was designed to share the amazing work that we are doing with the world and to make it simple for newcomers to get onboard to help with future projects.

## V1 Features
The main feature of the app is to keep people updated with our events and projects.  When a new event is posted, users of the app will be updated with information about the event and will have an opportunity to RSVP for it.  They will also be able to submit ideas for future projects, which we can vote on at a later time.

The app also spotlights the main contributors of the project.  Team leaders and top contributors show up on the top of the list in the community section.  

### Mentoring
As our platform grows, we hope to be able to take on new people, even those that are not experienced.  Through the [Hacksmiths.io Mentoring Program](http://hacksmiths.io/mentoring), we can match newcomers with a suitable mentor who can help show them the ropes on a real collaborative project.

### User sign up
The application allows for a user to sign up to be a member of our community.  Please note that signing to be a member of the community does not mean that you will participate in a project.  We will have to get to know you a bit first :D.  That said, we encourage anyone to signup.  Please read the [Privacy Policy](http://hacksmiths.io/privacy) policy if you have any concerns.  We will do our best to keep your information private, but please keep in mind that the point of the app and website is to connect people.  If you do not specifically set your profile to public, some of your information will be available through the app and website.

## App Architecture
The app utilizes the Model View Presenter pattern in an effort to make View Controllers lighter.  It utilizes Promises via PromiseKit to make asyncrhonous work much more elegant.  It uses Core Data to persist data to the device  It was built using XCode 7.3.1 for the iOS9+ plus platform.

The Application coordinates with a Node.js API that was written specifically for this project and is hosted at [Hacksmiths.io].  Most of the data for this project lives on the database server, although all models are persisted to disk to enable usage offline.

## Getting Started (If you care to install the app that is!)
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

### API Keys
The app contains a Plist file with API Keys.  For obvious reasons, I cannot distribute these.  Please reference the included ApiKeysDist.plist file.  Copying this to ApiKeys.plist will likely allow the app to be run, although some API functions will not work.

## Fastlane
This app is setup to utilize fastlane to automate the App Store Submission.  There are fastlane configuration files included with the repository.

## Built With
- XCode
- Swift
- Cocoapods

## Authors

* **Ryan Collins**

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments
Thanks to all of the wonder people in the [Hacksmiths]() and Udacity communities for making this project possible!  A special thanks to the wonderful employees of Udacity.  You are all such amazing people and the Hacksmiths would not be possible without you!

<div>Icon made by <a href="http://www.icomoon.io" title="Icomoon">Icomoon</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a> is licensed under <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>

## Roadmap
v0.0.1-Beta - As of May 2016, the Hacksmiths.io app is being beta tested, pending release to the Apple App Store.
v1.0 - Stay tuned for announcements regarding version 1.0!

## Troubleshooting
If for some reason, you run into issues installing, it's likely due to cocoapods.  What cocoapods does is it manages package dependencies for the project.  You need to make sure that you upen the .xcworkspace project because that is a requirement of cocoapods.

If you still have difficulties, please see the [CocoaPods troubleshooting guide](https://guides.cocoapods.org/using/troubleshooting.html)
