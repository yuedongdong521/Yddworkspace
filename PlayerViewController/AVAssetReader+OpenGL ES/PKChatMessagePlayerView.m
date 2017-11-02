//
//  PKChatMessagePlayerView.m
//  DevelopPlayerDemo
//
//  Created by jiangxincai on 16/1/11.
//  Copyright © 2016年 pepsikirk. All rights reserved.
//

#import "PKChatMessagePlayerView.h"
#import "PKVideoDecoder.h"
#import "GPUImageContextYDD.h"
#import "PKColorConversion.h"

@interface PKChatMessagePlayerView () <PKVideoDecoderDelegate> {
    GLuint displayRenderbuffer, displayFramebuffer;
    GLint displayPositionAttribute, displayTextureCoordinateAttribute;
    GLint displayInputTextureUniform;
    GLfloat imageVertices[8];
    GLfloat backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha;
}

@property (nonatomic, strong) GLProgramYDD *displayProgram;
@property (nonatomic, strong) GPUImageFramebufferYDD *inputFramebufferForDisplay;

@property (nonatomic, assign) CGSize inputImageSize;
@property (nonatomic, assign) CGSize boundsSizeAtFrameBufferEpoch;

@property (nonatomic, assign) GPUImageRotationMode rotationMode;

@property (nonatomic, readwrite) CGSize sizeInPixels;

@property (nonatomic, strong) PKVideoDecoder *decoder;

@end

@implementation PKChatMessagePlayerView

#pragma mark - Initialization

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath previewImage:(UIImage *)previewImage {
    NSParameterAssert(videoPath != nil);
    NSParameterAssert(previewImage != nil);
    
    self = [super initWithFrame:frame];
    if (self) {
        _videoPath = videoPath;
        _previewImage = previewImage;
        
        [self commonInit];
        _decoder = [[PKVideoDecoder alloc] initWithVideoPath:videoPath size:frame.size];
        _decoder.delegate = self;
        _isPlaying = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath {
    NSParameterAssert(videoPath != nil);
    self = [super initWithFrame:frame];
    if (self) {
        _videoPath = videoPath;
        [self commonInit];
        _decoder = [[PKVideoDecoder alloc] initWithVideoPath:videoPath size:frame.size];
        _decoder.delegate = self;
        _isPlaying = NO;
    }
    return self;
}
- (void)setVideoPath:(NSString *)videoPath
{
    NSParameterAssert(videoPath != nil);
    if (_videoPath != videoPath) {
        _videoPath = videoPath;
    }
    [self commonInit];
    _decoder.videoPath = _videoPath;
}

- (void)commonInit {
    // Set scaling to account for Retina display
    if ([self respondsToSelector:@selector(setContentScaleFactor:)]) {
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
    }
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.videoPath] options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        
        if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
            // Portrait
            self.rotationMode = kGPUImageRotateRight;
        } else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
            // PortraitUpsideDown
            self.rotationMode = kGPUImageRotateLeft;
        } else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
            // LandscapeRight
            self.rotationMode = kGPUImageNoRotation;
        } else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
            // LandscapeLeft
            self.rotationMode = kGPUImageRotate180;
        }
    }
    
    self.opaque = YES;
    self.hidden = NO;
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    runSynchronouslyOnVideoProcessingYddQueue(^{
        [GPUImageContextYDD useImageProcessingContext];
        
        self.displayProgram = [[GPUImageContextYDD sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderStr fragmentShaderString:kGPUImagePassthroughFragmentShaderStr];
        if (!self.displayProgram.initialized) {
            [self.displayProgram addAttribute:@"position"];
            [self.displayProgram addAttribute:@"inputTextureCoordinate"];
            
            if (![self.displayProgram link]) {
                NSString *progLog = [self.displayProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [self.displayProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [self.displayProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                self.displayProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        displayPositionAttribute = [self.displayProgram attributeIndex:@"position"];
        displayTextureCoordinateAttribute = [self.displayProgram attributeIndex:@"inputTextureCoordinate"];
        displayInputTextureUniform = [self.displayProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputTexture" for the fragment shader
        
        [GPUImageContextYDD setActiveShaderProgram:self.displayProgram];
        glEnableVertexAttribArray(displayPositionAttribute);
        glEnableVertexAttribArray(displayTextureCoordinateAttribute);
        
        [self setBackgroundColorRed:0.0 green:0.0 blue:0.0 alpha:1.0];

        [self createDisplayFramebuffer];
    });
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // The frame buffer needs to be trashed and re-created when the view size changes.
    if (!CGSizeEqualToSize(self.bounds.size, self.boundsSizeAtFrameBufferEpoch) &&
        !CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        runSynchronouslyOnVideoProcessingYddQueue(^{
            [self destroyDisplayFramebuffer];
            [self createDisplayFramebuffer];
        });
    } else if (!CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        [self recalculateViewGeometry];
    }
}

- (void)dealloc {
    runSynchronouslyOnVideoProcessingYddQueue(^{
        [self destroyDisplayFramebuffer];
    });
    [_decoder cancelProcessing];
}

#pragma mark - Public

- (void)play {
    if (_isPlaying == NO) {
        [self.decoder startProcessing];
        _isPlaying = YES;
    }
}

- (void)stop {
    if (_isPlaying == YES) {
        [self.decoder cancelProcessing];
        _isPlaying = NO;
    }
    runSynchronouslyOnVideoProcessingYddQueue(^{
        glFinish();
    });
}

#pragma mark Managing the display FBOs

- (void)createDisplayFramebuffer {
    [GPUImageContextYDD useImageProcessingContext];
    
    glGenFramebuffers(1, &displayFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
    
    glGenRenderbuffers(1, &displayRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    
    [[[GPUImageContextYDD sharedImageProcessingContext] context] renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    
    GLint backingWidth, backingHeight;
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    if ( (backingWidth == 0) || (backingHeight == 0) ) {
        [self destroyDisplayFramebuffer];
        return;
    }
    
    _sizeInPixels.width = (CGFloat)backingWidth;
    _sizeInPixels.height = (CGFloat)backingHeight;
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, displayRenderbuffer);
    
    __unused GLuint framebufferCreationStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(framebufferCreationStatus == GL_FRAMEBUFFER_COMPLETE, @"Failure with display framebuffer generation for display of size: %f, %f", self.bounds.size.width, self.bounds.size.height);
    self.boundsSizeAtFrameBufferEpoch = self.bounds.size;
    
    [self recalculateViewGeometry];
}

- (void)destroyDisplayFramebuffer {
    [GPUImageContextYDD useImageProcessingContext];
    
    if (displayFramebuffer) {
        glDeleteFramebuffers(1, &displayFramebuffer);
        displayFramebuffer = 0;
    }
    
    if (displayRenderbuffer) {
        glDeleteRenderbuffers(1, &displayRenderbuffer);
        displayRenderbuffer = 0;
    }
}

- (void)setDisplayFramebuffer {
    if (!displayFramebuffer) {
        [self createDisplayFramebuffer];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
    
    glViewport(0, 0, (GLint)_sizeInPixels.width, (GLint)_sizeInPixels.height);
}

- (void)presentFramebuffer {
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    [[GPUImageContextYDD sharedImageProcessingContext] presentBufferForDisplay];
}

#pragma mark Handling fill mode

- (void)recalculateViewGeometry {
    runSynchronouslyOnVideoProcessingYddQueue(^{
        CGFloat heightScaling, widthScaling;
        CGSize currentViewSize = self.bounds.size;
        CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(self.inputImageSize, self.bounds);
        
        widthScaling = insetRect.size.width / currentViewSize.width;
        heightScaling = insetRect.size.height / currentViewSize.height;
        
        imageVertices[0] = -widthScaling;
        imageVertices[1] = -heightScaling;
        imageVertices[2] = widthScaling;
        imageVertices[3] = -heightScaling;
        imageVertices[4] = -widthScaling;
        imageVertices[5] = heightScaling;
        imageVertices[6] = widthScaling;
        imageVertices[7] = heightScaling;
    });
}

- (void)setBackgroundColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent alpha:(GLfloat)alphaComponent; {
    backgroundColorRed = redComponent;
    backgroundColorGreen = greenComponent;
    backgroundColorBlue = blueComponent;
    backgroundColorAlpha = alphaComponent;
}

+ (const GLfloat *)textureCoordinatesForRotation:(GPUImageRotationMode)rotationMode; {
    static const GLfloat noRotationTextureCoordinates[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    static const GLfloat rotateRightTextureCoordinates[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotateLeftTextureCoordinates[] = {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat verticalFlipTextureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat horizontalFlipTextureCoordinates[] = {
        1.0f, 1.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotateRightVerticalFlipTextureCoordinates[] = {
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
    };
    
    static const GLfloat rotateRightHorizontalFlipTextureCoordinates[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotate180TextureCoordinates[] = {
        1.0f, 0.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
    };
    
    switch(rotationMode) {
        case kGPUImageNoRotation: return noRotationTextureCoordinates;
        case kGPUImageRotateLeft: return rotateLeftTextureCoordinates;
        case kGPUImageRotateRight: return rotateRightTextureCoordinates;
        case kGPUImageFlipVertical: return verticalFlipTextureCoordinates;
        case kGPUImageFlipHorizonal: return horizontalFlipTextureCoordinates;
        case kGPUImageRotateRightFlipVertical: return rotateRightVerticalFlipTextureCoordinates;
        case kGPUImageRotateRightFlipHorizontal: return rotateRightHorizontalFlipTextureCoordinates;
        case kGPUImageRotate180: return rotate180TextureCoordinates;
    }
}



#pragma mark - PKVideoDecoderDelegate

- (void)didDecodeInputFramebuffer:(GPUImageFramebufferYDD *)newInputFramebuffer inputSize:(CGSize)newSize frameTime:(CMTime)frameTime {
    self.inputFramebufferForDisplay = newInputFramebuffer;
    [self.inputFramebufferForDisplay lock];
    
    runSynchronouslyOnVideoProcessingYddQueue(^{
        CGSize rotatedSize = newSize;
        
        if (!CGSizeEqualToSize(self.inputImageSize, rotatedSize)) {
            self.inputImageSize = rotatedSize;
            [self recalculateViewGeometry];
        }
    });
    
    runSynchronouslyOnVideoProcessingYddQueue(^{
        [GPUImageContextYDD setActiveShaderProgram:self.displayProgram];
        [self setDisplayFramebuffer];
        
        glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, [self.inputFramebufferForDisplay texture]);
        glUniform1i(displayInputTextureUniform, 4);
        
        glVertexAttribPointer(displayPositionAttribute, 2, GL_FLOAT, 0, 0, imageVertices);
        glVertexAttribPointer(displayTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [PKChatMessagePlayerView textureCoordinatesForRotation:self.rotationMode]);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        [self presentFramebuffer];
        [self.inputFramebufferForDisplay unlock];
        self.inputFramebufferForDisplay = nil;
    });
}

-(void)didCompletePlayingMovie {
    
}

#pragma mark - Getter

- (CGSize)sizeInPixels {
    if (CGSizeEqualToSize(_sizeInPixels, CGSizeZero)) {
        if ([self respondsToSelector:@selector(setContentScaleFactor:)]) {
            CGSize pointSize = self.bounds.size;
            return CGSizeMake(self.contentScaleFactor * pointSize.width, self.contentScaleFactor * pointSize.height);
        }
        else {
            return self.bounds.size;
        }
    }
    else {
        return _sizeInPixels;
    }
}

@end
