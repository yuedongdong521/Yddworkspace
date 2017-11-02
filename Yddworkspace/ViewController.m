//
//  ViewController.m
//  Yddworkspace
//
//  Created by ispeak on 16/8/15.
//  Copyright © 2016年 QH. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import "YddImagePickerViewController.h"
#import "MyImagePickerViewController.h"
#import "MyTableViewController.h"
#import "AnimationViewController.h"
#import "Yddworkspace-swift.h"
#import "CoreTextViewController.h"
#import "IntrinsicViewController.h"
#import "ZhengZeViewController.h"
#import "AVCaptureSessionViewController.h"
#import "BezierPathViewController.h"
#import "UIViewController+KNSemiModal.h"



@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSMutableArray *myTestMtbArray;
@property (nonatomic, strong) NSArray *swiftArray;


@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.array = @[@[@"PlayerViewController", @"YddImagePickerViewController",@"MyImagePickerViewController",@"MyTableViewController",@"AnimationViewController",@"CoreTextViewController",@"BarrageViewController",@"GraffitiViewController",@"IFlyViewController",@"SpeekViewController",@"HZAViewController", @"VoiceToWordViewController",@"IntrinsicViewController",@"CameraViewController",@"MySpeekViewController",@"ZhengZeViewController",@"AVCaptureSessionViewController", @"BezierPathViewController", @"DrawImageColorViewController", @"MutableThreadViewController", @"GameLiveHomeViewController"], @[@"MyViewController", @"ClosureViewController"]];
    
    
    
    _myTestMtbArray = [NSMutableArray arrayWithObjects:@"1",@"2", @"3", @"4", nil];
    
    self.myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.view addSubview:self.myTableView];
    
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuse"];
//    MyModule *myModule = [MyModule mymodule];
//    NSString *str = [myModule getMyModuleTypeWithTag:0];
//    NSLog(@"%@", str);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"object_c";
    } else {
        return @"swift";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSArray *array = self.array[0];
        return array.count;
    } else {
        NSArray *array = self.array[section];
        return array.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse" forIndexPath:indexPath];
    NSArray *array = [self.array objectAtIndex:indexPath.section];
    cell.textLabel.text = [array objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (indexPath.section == 0) {
        NSArray *array = self.array[0];
        NSString *itemStr = array[indexPath.row];
        Class class = NSClassFromString(itemStr);
        if (class) {
            UIViewController *viewController = class.new;
            if ([viewController isKindOfClass:[MyImagePickerViewController class]] || [viewController isKindOfClass:[AVCaptureSessionViewController class]]) {
                [self presentViewController:viewController animated:YES completion:nil];
                return;
            }
            viewController.title = itemStr;
            //        viewController.view.backgroundColor = [UIColor whiteColor];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    } else {
        NSArray *array = self.array[indexPath.section];
        NSString *itemStr = array[indexPath.row];
        if ([itemStr isEqualToString:@"MyViewController"]) {
            [self pushSwiftViewController];
            return;
        } else if ([itemStr isEqualToString:@"ClosureViewController"]) {
            ClosureViewController *viewController = [ClosureViewController new];
            viewController.title = itemStr;
            viewController.view.backgroundColor = [UIColor whiteColor];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (void)pushMyCoreTextViewController
{
    CoreTextViewController *coreText = [[CoreTextViewController alloc] init];
    coreText.view.backgroundColor = [UIColor whiteColor];
    coreText.navigationController.title = @"CoreText";
    [self.navigationController pushViewController:coreText animated:YES];
}

- (void)pushSwiftViewController
{
    MyViewController *myViewController = [[MyViewController alloc] init];
    myViewController.testArray = [NSMutableArray arrayWithArray:_myTestMtbArray];
    myViewController.p_testArray = _myTestMtbArray;
    NSMutableArray *array = _myTestMtbArray;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_myTestMtbArray removeLastObject];
        NSLog(@"array = %@", array);
    });
    [self.navigationController pushViewController:myViewController animated:YES];
//    [self.navigationController presentViewController:myViewController animated:YES completion:nil];
//    [self presentSemiViewController:myViewController withOptions:@{
//                                                                  KNSemiModalOptionKeys.pushParentBack    : @(YES),
//                                                                  KNSemiModalOptionKeys.animationDuration : @(0.6),
//                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
//                                                                  KNSemiModalOptionKeys.backgroundView : [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_01"]]
//                                                                  }];
}


- (void)pushAnimationViewController
{
    AnimationViewController *animationViewController = [[AnimationViewController alloc] init];
    [self.navigationController pushViewController:animationViewController animated:YES];
}


- (void)pushMyTableViewController
{
    MyTableViewController *myTableViewController = [[MyTableViewController alloc] init];
    [self.navigationController pushViewController:myTableViewController animated:YES];
}

- (void)pushPlayerViewController
{
    PlayerViewController *playerViewController = [[PlayerViewController alloc] init];
    [self.navigationController pushViewController:playerViewController animated:YES];
}

- (void)pushYddImagePickerViewController
{
    YddImagePickerViewController *imagePickerVC = [[YddImagePickerViewController alloc] init];
    imagePickerVC.isCamera = YES;
    [self.navigationController pushViewController:imagePickerVC animated:YES];
}

- (void)pushMyImagePickerViewController
{
    MyImagePickerViewController *myImageVC = [[MyImagePickerViewController alloc] init];
    [self.navigationController pushViewController:myImageVC animated:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
