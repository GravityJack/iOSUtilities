//
//  GJConstants.h
//  Bcard
//
//  Created by Brad Flegel on 3/16/15.
//  Copyright (c) 2015 bcard. All rights reserved.
//

#ifndef GJiOSUtilities_GJConstants_h
#define GJiOSUtilities_GJConstants_h

#define USE_PRODUCTION_SERVER true

#if USE_PRODUCTION_SERVER
    #define kServerUrl @"https://EXAMPLE.PRODUCTION"
#else
    #define kServerUrl @"https://EXAMPLE.DEVELOPMENT"
#endif

#define IS_IPHONE_5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
#define IS_IPAD  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#endif
