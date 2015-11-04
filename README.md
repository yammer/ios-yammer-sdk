Yammer SDK and Sample iOS Application
=================================


Introduction
------------
The Yammer API opens Yammer networks to third-party application developers. This SDK
provides iOS developers with the code necessary to integrate Yammer functionality into mobile apps.
The sample app demonstrates a step-by-step process that does the following:

1. Allows users to login to the Yammer network using a modally presented web view
2. Obtains an authToken and stores it to the iOS keychain
3. Uses that authToken to make all subsequent calls to the Yammer API

In order to provide this functionality, some setup must be done.

SDK Integration
---------

The SDK has been packaged as a CocoaPod. You can include the SDK in your project by installing CocoaPods, creating a Podfile and specifying that you want to include the YammerSDK pod. The first step is to install CocoaPods using:
`sudo gem install cocoapods`

Then create a file called Podfile in your project's directory, open it with a text editor and add the following lines:
```ruby
platform :ios, '7.0'

target 'YOURTARGET' do

pod 'YammerSDK'

end
```
Next type `pod install` from the command line in your project's folder. From now on you should open your project from the .xcworkspace file that CocoaPods has created.

**Swift Integration**

Using the YammerSDK CocoaPod in a Swift project is quite straightforward. In addition to the steps outlined above you will need to create an Objective-C bridging header and import the YammerSDK.

In Xcode go to File->New and in the dialog that shows up go to source and select header file. Name the file YourProjectName-Bridging-Header.h and take note of the file path.

In the build settings for your project go to the section called "Swift Compiler - Code Generation" and change the "Objective-C Bridging Header" property so that it points to your bridging header. Note that the path to your bridging header is relative to your project's root directory, so you don't need to specify the path to your project. Your bridging header should look something like this:

```c
#ifndef test_Bridging_Header_h
#define test_Bridging_Header_h

#import "YammerSDK/YMAPIClient.h"
#import "YammerSDK/YMLoginClient.h"

#endif
```

App Setup
---------

**Step 1)** Create a Yammer application here: https://www.yammer.com/client_applications

**Step 2)** As part of the application setup in step 1, set the Redirect URI to a custom URI scheme. This must be unique to your iOS app. Here's an example: **comabccorpyammer1://our.custom.uri**
<br/>Make sure the scheme name (in this case "comabccorpyammer1") is unique to your company and iOS app.

**Step 3)** Add the following lines into your application's app delegate in the `application:didFinishLaunchingWithOptions:` method using values from [Yammer
client application](https://www.yammer.com/client_applications)

**Objective-C:**
```objectivec
/* Add your client ID here */
[[YMLoginClient sharedInstance] setAppClientID:@"APP CLIENT ID"];
    
/* Add your client secret here */
[[YMLoginClient sharedInstance] setAppClientSecret:@"APP CLIENT SECRET"];
    
/* Add your authorization redirect URI here */
[[YMLoginClient sharedInstance] setAuthRedirectURI:@"AUTH REDIRECT URI"];
```
**Swift:**
```swift
/* Add your client ID here */
YMLoginClient.sharedInstance().appClientID = "APP CLIENT ID"
    
/* Add your client secret here */
YMLoginClient.sharedInstance().appClientSecret = "APP CLIENT SECRET"
    
/* Add your authorization redirect URI here */
YMLoginClient.sharedInstance().authRedirectURI = "AUTH REDIRECT URI"
```

**Step 4)** Take a look at YMSampleHomeViewController.m to see a typical workflow for Yammer API calls and user authentication. Start with the `attemptYammerApiCall` method. This simulates what you would typically do in your application to access the Yammer API. The first thing the code does is determine if the authToken is already available in the keychain. If it is, it makes the API call using the authToken. If not, it initiates the login process.

The login code is in YMLoginClient.m and starts with the method `startLoginWithContextViewController:`.

Login process
-------------

`-[YMLoginClient startLoginWithContextViewController:]` presents the Yammer SSO flow modally in a view controller from the context view controller of your choice. The web view is launched
with a URL like this: `https://www.yammer.com/dialog/oauth?client_id=<your_client_id>&redirect_uri=<your_redirect_uri>`
<br/>
This brings up the login page where the user enters their credentials. After they type in their email address and password, they are presented with a page that will allow them to go back to the app where the rest of the authentication process takes place behind the scenes.

Once the redirect method completes successfully, the authToken is pulled from the returned JSON and stored in the keychain. All subsequent calls to the Yammer API use this authToken as the key into the system.

[urlScheme]: https://github.com/yammer/ios-oauth-demo/blob/master/URLSchemeExample.png?raw=true

