/* This file is part of mac2imgur.
*
* mac2imgur is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* mac2imgur is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with mac2imgur.  If not, see <http://www.gnu.org/licenses/>.
*/

// NSUserDefaults keys
public let kRefreshToken = "RefreshToken"
public let kUsername = "ImgurUsername"
public let kDeleteScreeenshotAfterUpload = "DeleteScreenshotAfterUpload"
public let kDisableScreenshotDetection = "DisableScreenshotDetection"
public let kRequiresUploadConfirmation = "RequiresUploadConfirmation"
public let kResizeScreenshots = "ResizeScreenshots"

// Imgur specific
public let imgurClientId = "5867856c9027819"
public let imgurClientSecret = "7c2a63097cbb0f10f260291aab497be458388a64"
public let imgurAllowedFileTypes = ["jpg", "jpeg", "gif", "png", "apng", "tiff", "bmp", "pdf", "xcf"]