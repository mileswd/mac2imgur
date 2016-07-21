# mac2imgur

![Platform](https://img.shields.io/badge/platform-macOS%2010.9+-lightgrey.svg)
[![Build Status](https://img.shields.io/travis/mileswd/mac2imgur.svg)](https://travis-ci.org/mileswd/mac2imgur)

![mac2imgur running on Yosemite](http://i.imgur.com/WrMhzbe.png)

A simple Mac application designed to make uploading images and screenshots to [imgur.com](https://imgur.com) quick and effortless.

## Installation

[Download the latest release.](https://mileswd.com/mac2imgur/latest)

## Usage

The application will listen for new screenshots taken by the [built in screenshot functionality of macOS](http://support.apple.com/kb/ht5775), so you can use the following shortcuts to capture your screen:

- Press **[CMD ⌘] - [SHIFT ⇧] - [3]** to take a full-screen screenshot

- Press **[CMD ⌘] - [SHIFT ⇧] - [4]** to take a rectangular selection of the screen

- Press **[CMD ⌘] - [SHIFT ⇧] - [4] - [SPACE]** to capture a specific window, menu or dialog

In addition, images can be uploaded manually by either:

- Dragging and dropping images on the status bar icon  (macOS 10.10+)
- Clicking the "Upload Images…" option in the status bar menu

As soon as an image is uploaded, the link is copied to your clipboard and a notification is sent:
![mac2imgur upload notification](https://i.imgur.com/V2PTN1l.png)

## Application Preferences

### General

| Preference Name | Description | Issue ID |
| --------------- | ----------- | -------- |
| Launch at Login | Allows mac2imgur to start as soon as you log in - this can also be changed from the `Login Items` tab of the `Users & Groups` pane of `System Preferences`. | [#53](https://github.com/mileswd/mac2imgur/issues/53) |
| Clear Clipboard | Clears the clipboard when an upload is taking place. | [#77](https://github.com/mileswd/mac2imgur/issues/77) |
| Copy Link to Clipboard | Copies the direct link to the uploaded image, if the upload completes successfully. | [#88](https://github.com/mileswd/mac2imgur/issues/88) |

### Screenshots

| Preference Name | Description | Issue ID |
| --------------- | ----------- | -------- |
| Delete After Upload | Causes the original screenshot file to be moved to trash after attempting to upload. | [#23](https://github.com/mileswd/mac2imgur/issues/23) |
| Disable Detection | Any new screenshots taken are ignored by the application and not uploaded. | [#30](https://github.com/mileswd/mac2imgur/issues/30) |
| Request Confirmation Before Upload | Screenshots are not uploaded automatically. Instead, an alert is displayed, showing the image and image name, allowing you to either proceed or cancel. | [#38](https://github.com/mileswd/mac2imgur/issues/38) |
| Downscale from Retina | Retina screenshots are resized (reducing resolution) before upload. [More Info.](https://cloudup.com/blog/the-retina-screenshot-problem) | [#52](https://github.com/mileswd/mac2imgur/issues/52) |

## System Preferences

Some aspects of the system screenshot functionality can be customized through `defaults`, including the following options:

| Key | Value | Result |
| --- | ----- | ------ |
| location | Any path, e.g. `/Users/[username]/Pictures` | Screenshots will be saved to the specified location, if it is valid. Otherwise, the default location (typically `~/Desktop`) will be used. |
| type | `png`, `jpg`, `gif`, `tiff` etc | The screenshot will be saved in the specified format. |
| name | Any string, e.g. `My Screenshot` | The screenshot file will be prefixed with the specified name, e.g. `My Screenshot 2016-07-10 at 17.42.17`. |

You can modify the defaults easily from `Terminal.app`:

`defaults write com.apple.screencapture <key> <value>`

`defaults delete com.apple.screencapture <key>`

### Examples

Save screenshots using the `JPG` format:

`defaults write com.apple.screencapture type jpg`

Revert the screenshot save location back to the system default:

`defaults delete com.apple.screencapture location`

### Further Information

More about `defaults` can be found from `defaults --help` and `man defaults`.

For any changes to take effect, you must restart `SystemUIServer`, which can be done through `Activity Monitor.app` or by running a command such as `killall SystemUIServer`.

When changing the screenshot location, it is also necessary to restart mac2imgur.

## Support

If you encounter any problems or have an idea for a new feature, don't hesitate to [file an issue](https://github.com/mileswd/mac2imgur/issues) - but please be as descriptive as possible! 

On the same note, pull requests to fix bugs, add features or simply to improve the codebase are greatly appreciated.

If you need help or would just like to say hello, I am also contactable via [Twitter](https://twitter.com/_mileswd) and by the email address listed on [my GitHub profile](https://github.com/mileswd).

## Development

- Written in Swift 3 (Xcode 8 beta 3)
- [CocoaPods](https://cocoapods.org) for dependency management

## Legal

mac2imgur is not affiliated with Imgur LLC, but this application would not be possible without the awesome service they offer - so feel free to show them some appreciation! :+1:

This application is released under a GPLv3 license. See [LICENSE](https://github.com/mileswd/mac2imgur/blob/master/LICENSE) for more information.
