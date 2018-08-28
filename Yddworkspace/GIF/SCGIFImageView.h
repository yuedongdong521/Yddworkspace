//
//  SCGIFImageView.h
//  TestGIF
//
//  Created by shichangone on 11-7-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SDWebImageCompat.h"
//#import "SDWebImageManagerDelegate.h"
//#import "SDWebImageManager.h"


@interface AnimatedGifFrame : NSObject
{
	NSData *data;
	NSData *header;
	double delay;
	int disposalMethod;
	CGRect area;
}

@property (nonatomic, copy) NSData *header;
@property (nonatomic, copy) NSData *data;
@property (nonatomic) double delay;
@property (nonatomic) int disposalMethod;
@property (nonatomic) CGRect area;

@end

@interface SCGIFImageView : UIImageView
{
	NSData *GIF_pointer;
	NSMutableData *GIF_buffer;
	NSMutableData *GIF_screen;
	NSMutableData *GIF_global;
	NSMutableArray *GIF_frames;
	
	int GIF_sorted;
	int GIF_colorS;
	int GIF_colorC;
	int GIF_colorF;
	int animatedGifDelay;
	
	int dataPointer;
}
@property (nonatomic, retain) NSMutableArray *GIF_frames;

- (id)initWithGIFFile:(NSString*)gifFilePath;
- (id)initWithGIFData:(NSData*)gifImageData;

- (BOOL)setGIFFile:(NSString*)gifFilePath;
- (BOOL)setCMImage:(UIImage*)cmImage;
- (BOOL)setGIFData:(NSData*)gifImageData;

- (void)loadImageData;

+ (NSMutableArray*)getGifFrames:(NSData*)gifImageData;
+ (BOOL)isGifImage:(NSData*)imageData;

- (void) decodeGIF:(NSData *)GIFData;
- (void) GIFReadExtensions;
- (void) GIFReadDescriptor;
- (bool) GIFGetBytes:(int)length;
- (bool) GIFSkipBytes: (int) length;
- (NSData*) getFrameAsDataAtIndex:(int)index;
- (UIImage*) getFrameAsImageAtIndex:(int)index;


/**
 * Set the imageView `image` with an `url`.
 *
 * The downloand is asynchronous and cached.
 *
 * @param url The url for the image.
 */
//- (void)setImageWithURL:(NSURL *)url;

/**
 * Set the imageView `image` with an `url` and a placeholder.
 *
 * The downloand is asynchronous and cached.
 *
 * @param url The url for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @see setImageWithURL:placeholderImage:options:
 */
//- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

/**
 * Set the imageView `image` with an `url`, placeholder and custom options.
 *
 * The downloand is asynchronous and cached.
 *
 * @param url The url for the image.
 * @param placeholder The image to be set initially, until the image request finishes.
 * @param options The options to use when downloading the image. @see SDWebImageOptions for the possible values.
 */
//- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;

/**
 * Cancel the current download
 */
//- (void)cancelCurrentImageLoad;


@end
