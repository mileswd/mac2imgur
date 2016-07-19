## ImgurSession

__ImgurSession__ is an Objective-C networking library to easily make [Imgur](http://imgur.com) API requests within iOS and OS X apps. It is built on [AFNetworking's](http://afnetworking.com/) AFHTTPSessionManager baseclass. ImgurSession provides access for V3 of the API. It handles OAuth2 authentication for user-authenticated sessions and also supports basic authentication for anonymous sessions. It covers all documented endpoints on Imgur's [documentation](https://api.imgur.com/). This is being used in production for my free app [Imgurian](http://imgur.com/gallery/63Gv6).

This project was originally forked from [ImgurKit](https://github.com/Nesk/ImgurKit) by Johann Pardanaud and since refactored.

## Features

- Full Imgur API V3
    - Use any of the Request classes in the ImgurSession/Request folder to make requests. Requests use Session singleton created before request was made.
    - CRUD actions for images, albums, comments, notifcations, messages, conversations, and accounts.
    - Multiple Image upload, upload from url.

- OAuth2 management. 
    - Session only needs your app credentials. Handles all authentication except for when it needs a webview. 
    - Session will refresh your tokens lazily. Feel free to use any request at any time.

- User account
    - Session notifies delegate of replies and messages to the users account automatically every 1 minute. Can be disabled.
    - Session refresh the user's account on token expiry every hour.


## Using ImgurSession

Just import ImgurSession.h and setup the session with your credentials before making any requests. For user authorization, you must register for OAuth 2 authorization with or without a callback URL depending on the token type (Read more at [Imgur](https://api.imgur.com/oauth2)). For authorized login, you must implement the delegate method imgurSessionNeedsExternalWebview: in order to open an external imgur.com page for OAuth authorization.

```

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
     [IMGSession authenticatedSessionWithClientID:@"clientID" secret:@"secret" authType:IMGCodeAuth withDelegate:self];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{

    /*
    configure you app URL schema to handle the callback url then call completion with retrieved code from URL
    */

}

#pragma mark - IMGSessionDelegate

-(void)imgurSessionNeedsExternalWebview:(NSURL *)url completion:(void (^)())completion{
    
    //open imgur website to authenticate with callback url in safari
    [[UIApplication sharedApplication] openURL:url];

    //save the completion block for later use when imgur responds with url callback
}

```

Or anonymous session (as configured by registered app on Imgur).

```
[IMGSession anonymousSessionWithClientID:@"anonToken" withDelegate:self];
```

Anywhere else in the app, make requests which will use the session singleton previously created to handle authentication and error handling. To retrieve the viral gallery:


```
    [IMGGalleryRequest hotGalleryPage:0 success:^(NSArray *objects) {
        
        //use gallery objects in a table for example
        self.tableRows = objects;
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        //handle error
    }];

```
