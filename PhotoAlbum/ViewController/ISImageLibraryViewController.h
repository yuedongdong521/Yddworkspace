//
//  ISImageLibraryViewController.h
//  iShow
//
//  Created by admin on 2017/5/26.
//
//

#import <UIKit/UIKit.h>

@interface ISImageLibraryViewController : UIViewController {
  UIImageView* imageView;
  UIImage* originalImages;

  CGRect cropFrame;
  CGRect oldFrame;
  CGRect largeFrame;
  CGFloat limitRatio;
  CGRect latestFrame;
}

@property(nonatomic, retain) UIImageView* imageView;
@property(nonatomic, retain) UIImage* originalImages;

@property(nonatomic, assign) CGRect cropFrame;
@property(nonatomic, assign) CGRect oldFrame;
@property(nonatomic, assign) CGRect largeFrame;
@property(nonatomic, assign) CGFloat limitRatio;
@property(nonatomic, assign) CGRect latestFrame;
@property(nonatomic, assign) NSInteger pushFlg;

@property(nonatomic, assign) NSInteger albumType;

@end
