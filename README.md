Yammer SDK and Sample iOS Application
=================================


Introduction
------------
The Yammer API opens Yammer networks to third-party application developers. This SDK
provides iOS developers with the code necessary to integrate Yammer functionality into mobile apps.
The sample app demonstrates a step-by-step process that does the following:

1. Allows users to login to the Yammer network using the iOS Safari browser
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

**Step 3)** During the login process, users will be directed to the mobile Safari web browser. In order for the browser to be able to switch back to your iOS app, the custom URL Scheme from step 2 must be registered in the iOS application. Here's how you do that:
<br/><br/>
In the XCode Project Navigator, expand the Supporting Files group and open your application's plist file. Add a new row by going to the menu and clicking Editor > Add Item. Select URL Types. Expand the URL Types key, expand Item 0, and add a new item: “URL schemes”. Fill in (for example) “comabccorpyammer1” for Item 0 of “URL schemes”. Under URL Types, add Item 1 and set that value to URL Identifier (example "our.custom.uri"). Here is a sample screenshot of that setting:

![URL Scheme Setup Example][urlScheme]

**Step 4)** Add the following lines into your application's app delegate in the `application:didFinishLaunchingWithOptions:` method using values from [Yammer
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

**Step 5)** Open the sample application's YMAppDelegate.m file and look at the method with this signature:

**Objective-C:**
```objective-c 
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
```
**Swift:**
```swift
func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool
```
This is the method that is called when the user has logged in and they click the "Allow" button in the safari login web page. That "Allow" button will call the custom URI from step 2 above. In order for your application to provide the same "re-entry" functionality, you need to add this app delegate method to your iOS app delegate.

**Note:** Once the server sees that a user has clicked the Allow button, future login requests do not display the page with the Allow button. This is a one time occurence for each unique user/yammer-app combination. Subsequent login attempts will return directly to the iOS app without the Allow page.

**Step 6)** Take a look at YMSampleHomeViewController.m to see a typical workflow for Yammer API calls and user authentication. Start with the `attemptYammerApiCall` method. This simulates what you would typically do in your application to access the Yammer API. The first thing the code does is determine if the authToken is already available in the keychain. If it is, it makes the API call using the authToken. If not, it initiates the login process.

The sample login code is in YMLoginClient.m and starts with the method `startLogin`. Feel free to copy and paste as much sample code as you'd like from the sample app into your own app, including copying class files, etc.

Login process
-------------

`-[YMLoginClient startLogin]` launches the iOS Safari web browser. The browser is launched
with a URL like this: `https://www.yammer.com/dialog/oauth?client_id=<your_client_id>&redirect_uri=<your_redirect_uri>`
<br/>
This brings up the login page where the user enters their credentials. After they type in their email address and password, they are presented with a page that will allow them to go back to the app where the rest of the authentication process takes place behind the scenes (`-[YMLoginClient handleLoginRedirectFromUrl:sourceApplication:]`)

Once the redirect method completes successfully, the authToken is pulled from the returned JSON and stored in the keychain. All subsequent calls to the Yammer API use this authToken as the key into the system.

Important Note:  The Safari browser in iOS will hold on to the authToken in a cookie in the browser. So if you have already logged in during testing, and you're trying to test the full login workflow again with the login dialog, you will need to delete cookies from Safari first. You can do this by going to the iOS settings app, selecting Safari and then Clear Cookies and Data. You will also need to delete the authToken from the keychain. There is a button on the YMSampleHomeViewController view that calls the deleteToken method so you can test this.

[urlScheme]: https://github.com/yammer/ios-oauth-demo/blob/master/URLSchemeExample.png?raw=true

