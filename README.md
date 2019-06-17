# habit-whitelabel-app-ios

This repository contains the source code to build a Habit Whitelabel application for iOS 

This Application interacts with the Habit Platform API in order to:
. Create new user Accounts and Login
. Pair IoT devices available to a specific application. To have devices available on your specific application please get in touch by sending us an email to support@habit.io.
. List and interact with the user’s paired devices
. Create and manage the user’s Agent list. These Agents are automation rules that enables integrations between different manufacturer devices.
. Possible to enable/disable a cards/messages screen, for you to be able to interact with your user. 
. User’s profile screen, where the user can define his preferences.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

In order to interact with the Habit API, clients must authenticate using the OAuth 2.0 protocol, in particular the Resource Owner Password Credentials flow. 
This project already implements the OAuth2.0 flow, you will just need to configure your client-id in the configuration file. To receive your client-id please get in touch with us by sending us an email to support@habit.io



### Installing


In order to run the project make sure you have Xcode 10.1 installed. Only this version of Xcode is supported at the moment.

The project uses CocoaPods dependency manager so ensure that it is installed. If it isn't you can install it by running:
```
$ sudo gem install cocoapods
```


To install the project dependencies run the following terminal command in the project directory: 
```
$ pod install
```

**Ensure that you open the project using the *muzzley-app.xcworkspace* file.**

## Deployment

To configure a Whitelabel, you have to alter the file Whitelabel.json with the information regarding your application. In this file you can configure colors, texts, links relevant to your app and other keys that are necessary for the app to run. The file is in JSON format and all the fields are required, except for the social networking urls (blog, facebook, twitter, website).

Throughout the project there are placeholders that need to be replaced in order for the project to compile and build successfully. The placeholder text is "-REPLACEME-". 

### Whitelabel.json configuration

In the Whitelabel.json file you can find fields that are mandatory in order for the application to run. Some of those fields are:

**app_id** - This is your application client ID to be used during the OAuth2.0 flow.

**application_name**  - Name of your application

**app_scheme** - Scheme used to open your application from other apps.

**namespace** - application namespace

**bundle_id** - Bundle ID that uniquely identifies your app in the Apple ecosystem.

**google_maps_api_key** -  a google maps key, compatible with Web, because it will be used on some webviews implemented in the application

Plugins 

**notifications_azure** -  this project receives push notification sent with the Azure provider. For you to have access to the feature you must have an active Azure account and configure a notification hub. Afterwards, your notification subscription endpoint should be placed here. Get in touch with us to be able to setup your publishing notification endpoint.

Colors: 

**primary_color** - Defines the color of navigation bars in the application.
**primary_color_text** - Defines the font color of navigation bars in the application.

**secondary_color** - Functionality to be added in the future.

**secondary_color_text** - Functionality to be added in the future.

**complementary_color** - Defines the color of onboarding screens.

**complementary_color_text** - Defines the text color of onboarding screens.

Features:

**cards**  - Enables/disables the tab that contains cards/messages

#### URLs: ####

**terms_services** - Terms and Services link (mandatory)

**privacy_policy** - Privacy policy link (mandatory)

Other links are optional and may not be included.

#### Copyright information is mandatory. ####

**localization_copy** - English (EN) copy is mandatory and the remaining languages are optional. 

**endpoints** - contains endpoints necessary for interacting with the platform.

### Project configuration

In the Project settings, select the Whitelabel target and replace the "-REPLACEME-" placeholders with the appropriate values. 

Make sure that in the Whitelabel target .plist file, the placeholders are also replaced. (Plist and URL Types section)


## Built With

Xcode 10.1 - IDE
* [Cocoapods](https://www.cocoapods.org/) 1.6.1 - Dependency Manager

## Versioning

For the versions available, see the [tags on this repository](https://github.com/habitio/habit-whitelabel-app-ios/tags). 

## Authors

See the list of [contributors](https://github.com/habitio/habit-whitelabel-app-ios/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details


