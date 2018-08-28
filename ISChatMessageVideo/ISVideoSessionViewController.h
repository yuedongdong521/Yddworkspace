//
//  ISVideoSessionViewController.h
//  iShow
//
//  Created by ispeak on 2018/1/3.
//

#import <UIKit/UIKit.h>

@protocol ISVideoSessionViewControllerDelegate <NSObject>

- (void)recordFinishWithVideoPath:(NSString*)videoPath
                WithThumbnailPath:(NSString*)thumbnailPath;

@end

@interface ISVideoSessionViewController : UIViewController

@property(nonatomic, weak) id<ISVideoSessionViewControllerDelegate> delegate;

@end
