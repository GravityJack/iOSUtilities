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

typedef enum {
    kGJ_RotateLeft,
    kGJ_RotateRight,
    kGJ_RotateFlip
} GJRotationDirection;

+ (void)setExclusiveTouchForAllButtonsOnView:(UIView *)myView;
+ (NSUserDefaults*)sharedUserDefaults;
+ (NSString*)encodeString:(NSString*)string;
+ (NSString*)urlEncode:(NSString*)string;
+ (NSDictionary*)removeNulls:(NSDictionary*)dict;
+ (NSString *)documentsPathForFileName:(NSString *)name;
+ (UIImage *)rotateImage:(UIImage *)image rotationDirection:(GJRotationDirection)direction;
+ (UIImage *)fixImageOrientation:(UIImage*)image;
+ (UIImage *)fixImageOrientation:(UIImage *)image fromOrientation:(UIImageOrientation)orientation;
+ (UIColor*)getPixelColorAtLocation:(CGPoint)point forImage:(UIImage*)image;

@end
