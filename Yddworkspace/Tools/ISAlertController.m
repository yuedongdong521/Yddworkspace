//
//  ISAlertController.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/25.
//  Copyright © 2019 QH. All rights reserved.
//

#import "ISAlertController.h"

@interface ISAlertWindow : UIWindow

@property (nonatomic, strong) NSMutableArray<ISAlertController*> *curAlerts;

@end

static ISAlertWindow* _alertWindow;

@implementation ISAlertWindow

+ (instancetype)shareAlertWindow {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _alertWindow = [[ISAlertWindow alloc] init];
    _alertWindow.windowLevel = 2000;
    _alertWindow.backgroundColor = [UIColor clearColor];
    UIViewController* vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor clearColor];
    _alertWindow.rootViewController = vc;
    _alertWindow.curAlerts = [NSMutableArray array];
  });
  return _alertWindow;
}

@end

@interface ISAlertController ()

@property(nonatomic, copy) void (^cancelBlock)();
@property(nonatomic, copy) void (^actionBlock)(NSInteger index);
@property(nonatomic, assign) BOOL isShowInWindow;

@end

@implementation ISAlertController

+ (id)alertWithTitle:(nullable NSString*)title
             message:(nullable NSString*)message
         cancelTitle:(nullable NSString*)cancelTitle
          otherTitle:(nullable NSString*)otherBtnTitle
         cancelBlock:(nullable void (^)())cancelBlock
         actionBlock:(nullable void (^)())actionBlock {
  return [self alertControllerWithTitle:title
                                message:message
                            cancelTitle:cancelTitle
                            otherTitles:otherBtnTitle ? @[ otherBtnTitle ] : nil
                                  style:UIAlertControllerStyleAlert
                            cancelBlock:cancelBlock
                            actionBlock:^(NSInteger index) {
                              if (actionBlock) {
                                actionBlock();
                              }
                            }];
}

+ (id)alertControllerWithTitle:(nullable NSString*)title
                       message:(nullable NSString*)message
                   cancelTitle:(nullable NSString*)cancelTitle
                   otherTitles:(nullable NSArray<NSString*>*)otherBtnTitles
                         style:(UIAlertControllerStyle)style
                   cancelBlock:(nullable void (^)())cancelBlock
                   actionBlock:(nullable void (^)(NSInteger index))actionBlock {
  ISAlertController* alert = [super alertControllerWithTitle:title
                                                     message:message
                                              preferredStyle:style];
  if (alert) {
    alert.cancelBlock = cancelBlock;
    alert.actionBlock = actionBlock;
    __weak ISAlertController* weakAlert = alert;
    if (cancelTitle && cancelTitle.length > 0) {
      UIAlertAction* cancelAction =
      [UIAlertAction actionWithTitle:cancelTitle
                               style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction* _Nonnull action) {
                               if (cancelBlock) {
                                 cancelBlock();
                               }
                               [weakAlert dismissWindow];
                             }];
      [alert addAction:cancelAction];
    }
    
    for (NSInteger i = 0; i < otherBtnTitles.count; i++) {
      UIAlertAction* action =
      [UIAlertAction actionWithTitle:otherBtnTitles[i]
                               style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction* _Nonnull action) {
                               if (actionBlock) {
                                 actionBlock(i);
                               }
                               [weakAlert dismissWindow];
                             }];
      [alert addAction:action];
    }
  }
  return alert;
}

+ (id)alertTextFieldWithTitle:(nullable NSString*)title
                      message:(nullable NSString*)message
                  placeholder:(nullable NSString*)placeholder
                  borderStyle:(UITextBorderStyle)borderStyle
                  cancelTitle:(nullable NSString*)cancelTitle
                   otherTitle:(nullable NSString*)otherTitle
                  cancelBlock:(nullable void (^)())cancelBlock
                  actionBlock:(nullable void (^)(NSString* text))actionBlock {
  ISAlertController* alert =
  [super alertControllerWithTitle:title
                          message:message
                   preferredStyle:UIAlertControllerStyleAlert];
  if (alert) {
    alert.cancelBlock = cancelBlock;
    __weak ISAlertController* weakAlert = alert;
    if (cancelTitle && cancelTitle.length > 0) {
      UIAlertAction* cancelAction =
      [UIAlertAction actionWithTitle:cancelTitle
                               style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction* _Nonnull action) {
                               if (cancelBlock) {
                                 cancelBlock();
                               }
                               [weakAlert dismissWindow];
                             }];
      [alert addAction:cancelAction];
    }
    
    UIAlertAction* action = [UIAlertAction
                             actionWithTitle:otherTitle
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction* _Nonnull action) {
                               if (actionBlock) {
                                 actionBlock(weakAlert.textFields.firstObject.text);
                               }
                               [weakAlert dismissWindow];
                             }];
    [alert addAction:action];
    
    [alert addTextFieldWithConfigurationHandler:^(
                                                  UITextField* _Nonnull textField) {
      textField.placeholder = placeholder;
      textField.borderStyle = borderStyle;
    }];
  }
  return alert;
}

+ (id)alertTextFieldsWithTitle:(nullable NSString*)title
                       message:(nullable NSString*)message
         textFieldsPlaceholder:(NSArray<NSString*>*)textFieldsPlaceholder
                   cancelTitle:(nullable NSString*)cancelTitle
                    otherTitle:(nullable NSString*)otherTitle
                   cancelBlock:(nullable void (^)())cancelBlock
                   actionBlock:
(nullable void (^)(NSArray<UITextField*>* textValues))
actionBlock {
  ISAlertController* alert =
  [super alertControllerWithTitle:title
                          message:message
                   preferredStyle:UIAlertControllerStyleAlert];
  if (alert) {
    alert.cancelBlock = cancelBlock;
    __weak ISAlertController* weakAlert = alert;
    if (cancelTitle && cancelTitle.length > 0) {
      UIAlertAction* cancelAction =
      [UIAlertAction actionWithTitle:cancelTitle
                               style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction* _Nonnull action) {
                               if (cancelBlock) {
                                 cancelBlock();
                               }
                               [weakAlert dismissWindow];
                             }];
      [alert addAction:cancelAction];
    }
    
    UIAlertAction* action =
    [UIAlertAction actionWithTitle:otherTitle
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction* _Nonnull action) {
                             if (actionBlock) {
                               actionBlock(weakAlert.textFields);
                             }
                             [weakAlert dismissWindow];
                           }];
    [alert addAction:action];
    
    for (int i = 0; i < textFieldsPlaceholder.count; i++) {
      [alert addTextFieldWithConfigurationHandler:^(
                                                    UITextField* _Nonnull textField) {
        textField.placeholder = textFieldsPlaceholder[i];
      }];
    }
  }
  return alert;
}

+ (id)alertCustomTextFieldWithTitle:(nullable NSString*)title
                            message:(nullable NSString*)message
                    customTextField:(UITextField *_Nonnull*)customTextField
                        cancelTitle:(nullable NSString*)cancelTitle
                         otherTitle:(nullable NSString*)otherTitle
                        cancelBlock:(nullable void (^)())cancelBlock
                        actionBlock:(nullable void (^)(NSString* text))actionBlock
{
  ISAlertController* alert =
  [super alertControllerWithTitle:title
                          message:message
                   preferredStyle:UIAlertControllerStyleAlert];
  if (alert) {
    alert.cancelBlock = cancelBlock;
    __weak ISAlertController* weakAlert = alert;
    if (cancelTitle && cancelTitle.length > 0) {
      UIAlertAction* cancelAction =
      [UIAlertAction actionWithTitle:cancelTitle
                               style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction* _Nonnull action) {
                               if (cancelBlock) {
                                 cancelBlock();
                               }
                               [weakAlert dismissWindow];
                             }];
      [alert addAction:cancelAction];
    }
    
    UIAlertAction* action =
    [UIAlertAction actionWithTitle:otherTitle
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction* _Nonnull action) {
                             if (actionBlock) {
                               actionBlock(weakAlert.textFields.firstObject.text);
                             }
                             [weakAlert dismissWindow];
                           }];
    [alert addAction:action];
    
    [alert addTextFieldWithConfigurationHandler:^(
                                                  UITextField* _Nonnull textField) {
      (*customTextField) = textField;
    }];
  }
  return alert;
}

- (void)showInViewController:(nullable UIViewController*)viewController {
  if (!viewController) {
    viewController = [self getNewCurrentViewController];
  }
  [viewController presentViewController:self animated:YES completion:nil];
}

- (void)dismissWithCancel:(BOOL)isCancel otherIndex:(NSInteger)otherIndex {
  if (isCancel) {
    if (self.cancelBlock) {
      self.cancelBlock();
    }
  } else {
    if (self.actionBlock) {
      self.actionBlock(otherIndex);
    }
  }
  [self dismissWindow];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissWindow {
  if (_isShowInWindow) {
    ISAlertWindow* alertWindow = [ISAlertWindow shareAlertWindow];
    [alertWindow.curAlerts removeObject:self];
    if (alertWindow.curAlerts.count == 0) {
      [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
      alertWindow.hidden = YES;
    } else {
      [alertWindow.curAlerts.lastObject showInWindow];
    }
  }
}

- (void)showInWindow {
  _isShowInWindow = YES;
  ISAlertWindow* alertWindow = [ISAlertWindow shareAlertWindow];
  [alertWindow.curAlerts addObject:self];
  alertWindow.hidden = NO;
  [alertWindow makeKeyAndVisible];
  [alertWindow.rootViewController presentViewController:self
                                               animated:YES
                                             completion:nil];
}

- (BOOL)isVisible {
  return _isShowInWindow;
}

- (UIViewController*)findBestViewController:(UIViewController*)vc {
  if (vc.presentedViewController) {
    // Return presented view controller
    return [self findBestViewController:vc.presentedViewController];
  } else if ([vc isKindOfClass:[UISplitViewController class]]) {
    // Return right hand side
    UISplitViewController* svc = (UISplitViewController*)vc;
    if (svc.viewControllers.count > 0)
      return [self findBestViewController:svc.viewControllers.lastObject];
    else
      return vc;
  } else if ([vc isKindOfClass:[UINavigationController class]]) {
    // Return top view
    UINavigationController* svc = (UINavigationController*)vc;
    if (svc.viewControllers.count > 0)
      return [self findBestViewController:svc.topViewController];
    else
      return vc;
  } else if ([vc isKindOfClass:[UITabBarController class]]) {
    // Return visible view
    UITabBarController* svc = (UITabBarController*)vc;
    if (svc.viewControllers.count > 0)
      return [self findBestViewController:svc.selectedViewController];
    else
      return vc;
  } else {
    // Unknown view controller type, return last child view controller
    return vc;
  }
}
// 出现alertView、Sheet时获取的不是VC是alterView,sheet,此种情况下建议使用[getNewCurrentViewController]
- (UIViewController*)getCurrentViewController {
  // Find best view controller
  UIViewController* viewController =
  [UIApplication sharedApplication].keyWindow.rootViewController;
  return [self findBestViewController:viewController];
}

- (UIViewController*)getNewCurrentViewController {
  UIViewController* viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
  return [self findBestViewController:viewController];
}


- (void)dealloc {
  NSLog(@"dealloc %@", self.class);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
