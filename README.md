[![Build Status](https://travis-ci.com/heremaps/msdkui-ios.svg?branch=master)](https://travis-ci.com/heremaps/msdkui-ios) [![codecov](https://codecov.io/gh/heremaps/msdkui-ios/branch/master/graph/badge.svg)](https://codecov.io/gh/heremaps/msdkui-ios)

# What is the HERE Mobile SDK UI Kit?
The HERE Mobile SDK UI Kit is a framework that provides modular and highly customizable user interface components that can be used on top of the HERE Mobile SDKs for iOS and Android ([Premium edition](https://developer.here.com/develop/mobile-sdks)).

![](https://github.com/heremaps/msdkui-ios/blob/master/Documentation/Guides/Images/UIKit_Intro.png?raw=true)

Rapidly build beautiful UIs for common use cases and scenarios within minutes. Version 2.x of the HERE Mobile SDK UI Kit will mainly focus on route planning, maneuver details and guidance. More components will follow subsequently with the next releases.

## Feature List
- Modular UI building blocks
- Native support for iOS and Android (including _Interface Builder_ on iOS and _Layout Editor_ on Android Studio)
- Ready-made styles for each component, adaptable on-the-fly
- Full support for all device orientations and screen sizes
- Already localized for 14+ languages
- Full accessibility support including voice over for customers with special needs
- Designed for the HERE Mobile SDK (iOS and Android, Premium edition)

## Component Overview
The HERE Mobile SDK UI Kit comes with various high- and low-level components supporting core use cases around the HERE Mobile SDK. Along with these components we deliver a rich set of supportive controls and tailored data structures to further reduce your development cost. All components can be freely arranged in your layouts and are highly customizable. More components will be delivered as part of the next releases. We already provide UI-centric support for the following features:

##### Route Planner
- Waypoint list (start,  stop, incl. support for stopovers, drag & drop sorting)
- Transport mode panel (to select transport type)
- Traffic options panel
- Different route options (including different sub-views for trucks like tunnel or hazardous goods)
- Travel time options and picker (to select departure or arrival times)

##### Route Summary
- Route description item (shows localized route details including user options)
- Route description list (shows alternative routes in an overview)

##### Route Maneuver
- Localized maneuver instructions and icons assembled out of the raw route data
- Maneuver item view (shows actions and turns)
- Maneuver table view (shows maneuver details of a route in an overview)

##### Guidance
- Localized guidance instructions and icons assembled out of the raw route data
- Guidance maneuver view to show upcoming actions and turns during navigation - an additional component is available to show the maneuver actions after the next maneuver
- Guidance street label view (shows the street a driver is currently on)
- Guidance estimated arrival view (displays estimated arrival information, such as estimated arrival time (ETA), estimated time to destination, and remaining travel distance)
- Guidance speed / guidance speed limit views (shows current speed and speed limit information)

## Localization
The HERE Mobile SDK UI Kit is already fully localized for the following languages:

- Chinese (Taiwan)
- English (UK)
- English (US)
- Filipino
- French
- German
- Hindi
- Italian
- Polish
- Portuguese (Brazil)
- Spanish (Spain)
- Turkish
- Ukrainian
- Vietnamese

## Supported platforms
The HERE Mobile SDK UI Kit components are available for iOS and [Android](https://github.com/heremaps/msdkui-android). The required HERE Mobile SDK is Version 3.12.2, only the _Premium edition_ is supported. The HERE Mobile SDK UI Kit supports scooter routing. Please, make sure to extend your license key if you want to include scooter routing in your app.

### iOS Environment
- The HERE Mobile SDK UI Kit supports Xcode 10.3, Swift 5.0 and CocoaPods 1.7.5.
- Minimum deployment target is iOS 10.0.

## Quick Start
Please have a look at our [Quick Start](https://github.com/heremaps/msdkui-ios/blob/master/Documentation/Guides/QuickStart.md) tutorial to see how easy it is to integrate the HERE Mobile SDK UI Kit into your own apps. More information on how to use the HERE Mobile SDK UI Kit can be found in our [User Guide](https://github.com/heremaps/msdkui-ios/blob/master/Documentation/Guides/UserGuide.md). Information on how to contribute to this project can be found in our [Contribution Guide](https://github.com/heremaps/msdkui-ios/blob/master/Documentation/Guides/ContributionGuide.md).

## Documentation
- The latest API Reference can be found [here](https://heremaps.github.io/msdkui-ios/).
- _Release Notes_: All recent additions, more details about the current release and the differences to previous versions can be found in the _Release Notes_.
- You can find various _examples_ and _code snippets_ accompanying the Developer's Guide.
- A more complex and fully functional _demo app_ can be found in this repository.

## Get in Touch
We are happy to hear your feedback. Please [contact us](https://developer.here.com/contact-us) for any questions, suggestions or improvements. Thank you for your using the HERE Mobile SDK UI Kit.

## License
Copyright (C) 2017-2019 HERE Europe B.V.

See the [LICENSE](https://github.com/heremaps/msdkui-ios/blob/master/LICENSE) file in the root of this project for license details.
