#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "GPUImageFramebufferYDD.h"

@interface GPUImageFramebufferCacheYDD : NSObject

// Framebuffer management
- (GPUImageFramebufferYDD *)fetchFramebufferForSize:(CGSize)framebufferSize textureOptions:(GPUTextureOptions)textureOptions onlyTexture:(BOOL)onlyTexture;
- (GPUImageFramebufferYDD *)fetchFramebufferForSize:(CGSize)framebufferSize onlyTexture:(BOOL)onlyTexture;
- (void)returnFramebufferToCache:(GPUImageFramebufferYDD *)framebuffer;
- (void)purgeAllUnassignedFramebuffers;
- (void)addFramebufferToActiveImageCaptureList:(GPUImageFramebufferYDD *)framebuffer;
- (void)removeFramebufferFromActiveImageCaptureList:(GPUImageFramebufferYDD *)framebuffer;

@end
