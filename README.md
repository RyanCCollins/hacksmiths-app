![Hacksmiths Logo](https://rawgit.com/teamhacksmiths/food-drivr-backend/master/.github/assets/hacksmiths-logo.png)

# Hackmiths Mobile App
### Made with ❤️ by Ryan Collins - Founder of [Hacksmith.io](http://hacksmiths.io)

Hacksmiths was built to provide a platform for Udacity students to collaborate on meaningful projects for social good.  Our debut project, the [Food Drivr App](https://github.com/teamhacksmiths/food-drivr), a web and mobile application designed to make the process of donating edible food as easy as pushing a button, is nearing public release as of late May 2016.

The Hacksmiths.io website and iOS mobile application was designed to give the members of the Hacksmiths an opportunity to connect with other Hacksmiths from around the world.  Through the app and website, people can learn about the projects we are working on, connect with the main contributors, join the community on Slack and more.  It has lead people from all over the world to come on to help us and this is just the beginning!

## V1 Features

#### Overview
The main feature of the app is to keep people updated with our events and projects.  When a new event is posted via the API, users of the app will be updated with information about the event and will have an opportunity to RSVP to participate in the event.  They will also be able to submit ideas for future projects, which we can vote on at a later time.

The app also spotlights the main contributors of the project.  Team leaders and top contributors show up on the top of the list in the community section.

### Sections of the App
1. Signup / Register

  The user is greeted with a signup / Registration Screen.  Clicking Sign up will take then through a three step registration process.  Clicking sign in will allow them to sign in.  Registration will create an account for the user on Hacksmiths.io and Sign in will sync the app with the user's profile on the Hacksmiths.io website.
2. Me / Settings

  When signed in, the user is shown a profile page, which will show the data that will be shown to the public (bio and photo).  Tapping the edit button on the top right will let the user edit a few of their profile fields.  Some of these fields only show when the a specific toggle is turned on for the user from the Settings section.
  
  The user has a number of settings, available from the Gear button slide out menu.  Tapping these will toggle them on and off both on the device and on the API.
3. Community / People

    The Community Section is one of the highlights of this app.  It shows a list of the Leaders and Community Members of the Hacksmiths in a table view.  The table view can be searched by name using the search bar, which will momentarily reorder the top hit to the top of the list.  Clicking a person will bring you to a Person page that shows that person's public information.  Pulling down the the tableview will reload the list in case there were any changes made on the API.
    
4. Event
    
  The Event page shows the current event as it is stored on the API.  It shows an overview of information about the event, including the date, place, details, additional marketing information, about the non profit, and finally a list of the participants.  During an Active Event, the user of the app has an opportunity to RSVP to help for an event through the app.  They will be added as a participant when they RSVP.  The final section on the Event page is a collection view containing the participants of the current event.  These are people that RSVPed and the data comes from the API.
5. Ideas 
  
  Possibly the most simple section, the Ideas section allows signed in users to submit an idea for a project that will get sent to our API. At a later point, we will release a mechanism to have our users vote on their favorite ideas.  For now, we are only collecting them.  A user can submit one idea per event.  The idea gets sent to the API and will send out an email to the Admins of Hackmsiths.io.  If a user tries to submit another idea during the same event, they will be told that they can edit their last submission.

6. About

  The About section shows information about the Hacksmiths and the founders.  It will also show a Terms of Service when this app is released to the App Store.

#### Mentoring
As our platform grows, we hope that new people will join us to help with our projects. We encourage people of any experience level to join us. Through the [Hacksmiths.io Mentoring Program](http://hacksmiths.io/mentoring), we can match newcomers with a suitable mentor who can help show them the ropes on a real collaborative project.  Please stay tuned for announcements on how this will work.  For now, if you have a profile, check off that you are looking for a mentor and what experience you'd like to gain.

#### User sign up
The application allows for a user to sign up to be a member of our community.  Please note that signing to be a member of the community does not mean that you will participate in a project.  We will have to get to know you a bit first :D.  That said, we encourage anyone to signup.  Please read the [Privacy Policy](http://hacksmiths.io/privacy) policy if you have any concerns.  We will do our best to keep your information private, but please keep in mind that the point of the app and website is to connect people.  If you do not specifically set your profile to public, some of your information will be available through the app and website.

## App Architecture
The app utilizes the Model View Presenter pattern in an effort to make View Controllers lighter.  It utilizes Promises via PromiseKit to make asyncrhonous work much more elegant.  It uses Core Data to persist data to the device  It was built using XCode 7.3.1 for the iOS9+ plus platform.

The Application coordinates with a Node.js API that was written specifically for this project and is hosted at [Hacksmiths.io].  Most of the data for this project lives on the database server, although all models are persisted to disk to enable usage offline.

### Technical Review
This app was code reviewed by an expert iOS Developer / Reviewer, who had this to say: "This is one of the best apps I've reviewed. Your coding style is amazing and reading the code was a breeze. Also the design was especially professional and reminded me a few popular apps.".  [Read the review](https://review.udacity.com/#!/reviews/159729).

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
The app contains a Plist file with API Keys.  For obvious reasons, I cannot distribute these.  Please reference the included ApiKeysDist.plist file.  Copying this to ApiKeys.plist will likely allow the app to be run, although some API functions will not work.  To copy the file, run the following command from the root directory of the project.
```
cp APIKeysDist.plist APIKeys.plist
```

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
Thanks to all of the wonderful people in the [Hacksmiths](https://hacksmiths.io) and [Udacity](https://udacity.com) communities for making this project possible!  A special thanks to the wonderful employees of Udacity.  You are all such amazing people and the Hacksmiths would not be possible without you!

<div>Icon made by <a href="http://www.icomoon.io" title="Icomoon">Icomoon</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a> is licensed under <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>

## Roadmap
v0.0.1-Beta - As of May 2016, the Hacksmiths.io app is being beta tested, pending release to the Apple App Store.
v1.0 - Stay tuned for announcements regarding version 1.0!

## Troubleshooting
If for some reason, you run into issues installing, it's likely due to cocoapods.  What cocoapods does is it manages package dependencies for the project.  You need to make sure that you open the .xcworkspace project because that is a requirement of cocoapods.

If you still have difficulties, please see the [CocoaPods troubleshooting guide](https://guides.cocoapods.org/using/troubleshooting.html)

## Screenshots
![Hacksmiths landing](https://raw.githubusercontent.com/RyanCCollins/hacksmiths-app/master/IMG_0408%202_iphone6plus_gold_side2.png)
![Hacksmiths app](https://raw.githubusercontent.com/RyanCCollins/hacksmiths-app/master/IMG_0405_iphone6plus_gold_side2.png)
![Hacksmiths event](https://raw.githubusercontent.com/RyanCCollins/hacksmiths-app/master/IMG_0406_iphone6plus_gold_side2.png)

## Timeline / Todos
* [ ] Release to App Store
* [ ] Update to unidirectional Data Flow
