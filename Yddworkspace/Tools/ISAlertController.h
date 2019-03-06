//
//  ISAlertController.h
//  Yddworkspace
//
//  Created by ydd on 2019/1/25.
//  Copyright © 2019 QH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ISAlertController : UIAlertController
/** AlertController是否处于活跃状态，是否显示在当前 window */
@property(nonatomic, assign, readonly) BOOL isVisible;

/**
 创建最常用的 UIAlertControllerStyleAlert，只有两个选择
 */
+ (id)alertWithTitle:(nullable NSString*)title
             message:(nullable NSString*)message
         cancelTitle:(nullable NSString*)cancelTitle
          otherTitle:(nullable NSString*)otherBtnTitle
         cancelBlock:(nullable void (^)())cancelBlock
         actionBlock:(nullable void (^)())actionBlock;

+ (id)alertControllerWithTitle:(nullable NSString*)title
                       message:(nullable NSString*)message
                   cancelTitle:(nullable NSString*)cancelTitle
                   otherTitles:(nullable NSArray<NSString*>*)otherBtnTitles
                         style:(UIAlertControllerStyle)style
                   cancelBlock:(nullable void (^)())cancelBlock
                   actionBlock:(nullable void (^)(NSInteger index))actionBlock;

/**
 创建单个 textField 的alertController
 
 @param title <#title description#>
 @param message <#message description#>
 @param placeholder textField 提示语
 @param borderStyle 键盘样式
 @param cancelTitle <#cancelTitle description#>
 @param otherTitle <#otherTitle description#>
 @param cancelBlock <#cancelBlock description#>
 @param actionBlock <#actionBlock description#>
 @return <#return value description#>
 */
+ (id)alertTextFieldWithTitle:(nullable NSString*)title
                      message:(nullable NSString*)message
                  placeholder:(nullable NSString*)placeholder
                  borderStyle:(UITextBorderStyle)borderStyle
                  cancelTitle:(nullable NSString*)cancelTitle
                   otherTitle:(nullable NSString*)otherTitle
                  cancelBlock:(nullable void (^)())cancelBlock
                  actionBlock:(nullable void (^)(NSString* text))actionBlock;
/**
 创建多个 textField 的alertController
 */
+ (id)alertTextFieldsWithTitle:(nullable NSString*)title
                       message:(nullable NSString*)message
         textFieldsPlaceholder:(NSArray<NSString*>*)textFieldsPlaceholder
                   cancelTitle:(nullable NSString*)cancelTitle
                    otherTitle:(nullable NSString*)otherTitle
                   cancelBlock:(nullable void (^)())cancelBlock
                   actionBlock:
(nullable void (^)(NSArray<UITextField*>* textValues))
actionBlock;

+ (id)alertCustomTextFieldWithTitle:(nullable NSString*)title
                            message:(nullable NSString*)message
                    customTextField:(UITextField *_Nonnull*)customTextField
                        cancelTitle:(nullable NSString*)cancelTitle
                         otherTitle:(nullable NSString*)otherTitle
                        cancelBlock:(nullable void (^)())cancelBlock
                        actionBlock:(nullable void (^)(NSString* text))actionBlock;


- (void)showInViewController:(nullable UIViewController*)viewController;

/**
 主动调用，让alert 消失
 
 @param isCancel YES 时消失会调用 cancel block，
 @param otherIndex 当 isCanncel = NO 时，返回所选择的otherBtnTitles index
 */
- (void)dismissWithCancel:(BOOL)isCancel otherIndex:(NSInteger)otherIndex;
- (void)showInWindow;

@end

NS_ASSUME_NONNULL_END
