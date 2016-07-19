//
//  ImgurSession.h
//  ImgurSession
//
//  Created by Xtreme Dev on 2014-03-19.
//  Copyright (c) 2014 GeoffMacDonald. All rights reserved.
//


//iOS 7 or OS X 10.9 only
#if ( ( defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED >= 1090) || \
( defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000 ) )

    #ifndef __ImgurSession__
        #define __ImgurSession__

        #import "IMGSession.h"

        #import "IMGAccountRequest.h"
        #import "IMGAlbumRequest.h"
        #import "IMGCommentRequest.h"
        #import "IMGConversationRequest.h"
        #import "IMGGalleryRequest.h"
        #import "IMGImageRequest.h"
        #import "IMGNotificationRequest.h"
        #import "IMGMemeGen.h"

        #import "IMGObject.h"
        #import "IMGGalleryObject.h"

        #import "IMGAccount.h"
        #import "IMGAccountSettings.h"
        #import "IMGAlbum.h"
        #import "IMGBasicAlbum.h"
        #import "IMGComment.h"
        #import "IMGConversation.h"
        #import "IMGNotification.h"
        #import "IMGGalleryAlbum.h"
        #import "IMGGalleryImage.h"
        #import "IMGGalleryProfile.h"
        #import "IMGImage.h"
        #import "IMGMessage.h"
        #import "IMGMeme.h"
        #import "IMGVote.h"

    #endif

#endif