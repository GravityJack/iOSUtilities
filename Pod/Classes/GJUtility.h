//
//  GJUtility.h
//  GJiOSUtilities
//
//  Created by Brad Flegel and Ryan Kennedy on 1/14/15.
//  Copyright (c) 2015 GravityJack Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GJUtility : NSObject

+ (void)setExclusiveTouchForAllButtonsOnView:(UIView *)myView;
+ (NSUserDefaults*)sharedUserDefaults;
+ (NSString*)encodeString:(NSString*)string;
+ (NSString*)urlEncode:(NSString*)string;
+ (NSDictionary*)removeNulls:(NSDictionary*)dict;
+ (NSString *)documentsPathForFileName:(NSString *)name;
+ (UIImage *)fixImageOrientation:(UIImage*)image;
+ (UIColor*)getPixelColorAtLocation:(CGPoint)point forImage:(UIImage*)image;

@end
