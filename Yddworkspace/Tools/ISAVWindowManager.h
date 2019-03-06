//
//  ISAVWindowManager.h
//  iSpeak
//
//  Created by ydd on 2018/4/21.
//

#import <Foundation/Foundation.h>

@interface ISAVWindowManager : NSObject

@property(nonatomic, strong) UIWindow* avWindow;

+ (ISAVWindowManager*)shareManager;

- (void)setRootViewController:(UIViewController*)vc;

- (void)destroyAvWindowCompletion:(void (^)())completion;

@end
