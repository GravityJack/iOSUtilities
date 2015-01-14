//
//  GJUtility.m
//  GJiOSUtilities
//
//  Created by Brad Flegel and Ryan Kennedy on 1/14/15.
//  Copyright (c) 2015 GravityJack Inc. All rights reserved.
//

#import "GJUtility.h"

@implementation GJUtility

+ (void)setExclusiveTouchForAllButtonsOnView:(UIView *)myView {
    
    for (UIView *v in [myView subviews]) {
        
        if([v isKindOfClass:[UIButton class]]) {
            
            [((UIButton *)v) setExclusiveTouch:YES];
            
        } else if ([v isKindOfClass:[UIView class]]){
            
            [self setExclusiveTouchForAllButtonsOnView:v];
        }
    }
}

+ (NSUserDefaults*)sharedUserDefaults {
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"entitlements" ofType:@"plist"];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString* appGroup = dict[@"AppGroup"];
    
    return [[NSUserDefaults alloc] initWithSuiteName:appGroup];
}

+ (NSString *)encodeString:(NSString*)string {
    
    NSMutableString* mString = [NSMutableString stringWithString:string];
    [mString replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, mString.length)];
    
    return mString;
}

+ (NSString *)urlEncode:(NSString*)string {
    
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

+ (NSDictionary *)removeNulls:(NSDictionary*)dict {
    
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    
    for(NSString* key in dict) {
        
        if([dict[key] isEqual:[NSNull null]]) {
            
            [result setObject:@"" forKey:key];
        
        } else if([dict[key] isKindOfClass:[NSDictionary class]]) {
            
            [result setObject:[GJUtility removeNulls:dict[key]] forKey:key];

        } else {

            [result setObject:dict[key] forKey:key];
        }
    }
    
    return result;
}

+ (NSString *)documentsPathForFileName:(NSString *) name {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

+ (UIImage *)fixImageOrientation:(UIImage*)image {
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIColor*)getPixelColorAtLocation:(CGPoint)point forImage:(UIImage*)image {
    
    @try {
        UIColor* color = nil;
        CGImageRef inImage = image.CGImage;
        // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
        CGContextRef cgctx = [GJUtility createARGBBitmapContextFromImage:inImage];
        if (cgctx == NULL) { return nil; /* error */ }
        
        size_t w = CGImageGetWidth(inImage);
        size_t h = CGImageGetHeight(inImage);
        CGRect rect = {{0,0},{w,h}};
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(cgctx, rect, inImage);
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        unsigned char* data = CGBitmapContextGetData (cgctx);
        if (data != NULL) {
            //offset locates the pixel in the data from x,y.
            //4 for 4 bytes of data per pixel, w is width of one row of data.
            int offset = 4*((w*round(point.y))+round(point.x));
            int alpha =  data[offset];
            int red = data[offset+1];
            int green = data[offset+2];
            int blue = data[offset+3];
            //        NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
            color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        }
        
        // When finished, release the context
        CGContextRelease(cgctx);
        // Free image data memory for the context
        if (data) { free(data); }
        
        return color;
    }
    @catch (NSException *exception) {
        return [UIColor blackColor];
    }
    @finally {
    }
}

+ (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef) inImage {
    @try {
        
        CGContextRef    context = NULL;
        CGColorSpaceRef colorSpace;
        void *          bitmapData;
        int             bitmapByteCount;
        int             bitmapBytesPerRow;
        
        // Get image width, height. We'll use the entire image.
        size_t pixelsWide = CGImageGetWidth(inImage);
        size_t pixelsHigh = CGImageGetHeight(inImage);
        
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        bitmapBytesPerRow   = (int)(pixelsWide * 4);
        bitmapByteCount     = (int)(bitmapBytesPerRow * pixelsHigh);
        
        // Use the generic RGB color space.
        colorSpace = CGColorSpaceCreateDeviceRGB(); //CGColorSpaceCreateWithName(kCGColorSpaceModelRGB);
        if (colorSpace == NULL)
        {
            fprintf(stderr, "Error allocating color space\n");
            return NULL;
        }
        
        // Allocate memory for image data. This is the destination in memory
        // where any drawing to the bitmap context will be rendered.
        bitmapData = malloc( bitmapByteCount );
        if (bitmapData == NULL)
        {
            fprintf (stderr, "Memory not allocated!");
            CGColorSpaceRelease( colorSpace );
            return NULL;
        }
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        context = CGBitmapContextCreate (bitmapData,
                                         pixelsWide,
                                         pixelsHigh,
                                         8,      // bits per component
                                         bitmapBytesPerRow,
                                         colorSpace,
                                         kCGImageAlphaPremultipliedFirst);
        if (context == NULL)
        {
            free (bitmapData);
            fprintf (stderr, "Context not created!");
        }
        
        // Make sure and release colorspace before returning
        CGColorSpaceRelease( colorSpace );
        
        return context;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
    }
}

@end
