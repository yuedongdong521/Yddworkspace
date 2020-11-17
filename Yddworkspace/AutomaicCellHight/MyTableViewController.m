//
//  MyTableViewController.m
//  Yddworkspace
//
//  Created by ispeak on 16/10/14.
//  Copyright © 2016年 QH. All rights reserved.
//

#import "MyTableViewController.h"
#import "MyTableViewCell.h"
#import "MyTableViewModel.h"
#import "MJRefresh.h"

typedef enum : NSUInteger {
    ContentTypeOne,
    ContenTypeTow,
} ContentType;

@interface MyTableViewController ()<UITableViewDelegate, UITableViewDataSource, MyTableViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *dataArray;
@property (nonatomic, retain) UITextField *textField;

@property (nonatomic, retain) MyTableViewModel *myTableViewModel;
@property (nonatomic, assign) NSInteger contentType;

@end

@implementation MyTableViewController

/*************
    content
 *************/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.navigationController.navigationBar.translucent = NO;
  
    [self initModel];
    [self initTableView];
    
    [self initTextField];
    
    //注册键盘出现通知；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    //注册键盘消失通知；
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)name:UIKeyboardDidHideNotification object:nil];
    
    
}

- (void)initTextField
{
    self.textField = [[UITextField alloc] init];
    self.textField.frame = CGRectMake(10, ScreenHeight - 40, ScreenWidth - 20, 40);
    self.textField.layer.borderWidth = 0.2;
    self.textField.layer.cornerRadius = 5.0;
    self.textField.layer.masksToBounds = YES;
    self.textField.layer.borderColor = [UIColor grayColor].CGColor;
    self.textField.delegate = self;
    self.textField.returnKeyType = UIReturnKeySend;
    [self.view addSubview:self.textField];
}

- (void)hiddenKeyboard
{
    [self.textField resignFirstResponder];
}


- (void)initModel
{
    NSArray *soursArray = [NSArray arrayWithObjects: @{@"uid":[NSNumber numberWithInt:137732173],
                                                     @"name":@"朵拉",
                                                     @"headImage":@"duo1",
                                                     @"loaction":@"日本 东京",
                                                     @"contentString":@"上海杨浦市重点毕业，目前在日本东京读大一，会三种语言",
                                                     @"isOpen":[NSNumber numberWithBool:NO],
                                                     @"comments":@[@"ydd:hdsjla我会的开始"]
                                                     },
                  @{@"uid":[NSNumber numberWithInt:103717147],
                    @"name":@"依然",
                    @"headImage":@"yr1",
                    @"loaction":@"美国",
                    @"contentString":@"北京市朝阳区重点毕业，目前就读于哈佛MBI，会四种语言",
                    @"isOpen":[NSNumber numberWithBool:NO],
                    @"comments":@[@"ydd:垃圾的路上就拉倒类似的领导说了算的深刻的塑料袋卡德加撒垃圾的",@"ydd:djsldjaldjladlsdak还得靠谁会卡的还是卡号的类似的骄傲了的塑料袋里睡觉了大家平时都软件而立即开始的"]
                    },
                  @{@"uid":[NSNumber numberWithInt:139496775],
                    @"name":@"cool",
                    @"headImage":@"cool1",
                    @"loaction":@"艾欧尼亚",
                    @"contentString":@"瓦罗兰大陆重点，目前就读于德玛西亚，会5种语言",
                    @"isOpen":[NSNumber numberWithBool:NO],
                    @"comments":@[]
                    },@{@"uid":[NSNumber numberWithInt:137732173],
                        @"name":@"朵拉",
                        @"headImage":@"duo1",
                        @"loaction":@"日本 东京",
                        @"contentString":@"上海杨浦市重点毕业，目前在日本东京读大一，会三种语言",
                        @"isOpen":[NSNumber numberWithBool:NO],
                        @"comments":@[]
                        },
                           @{@"uid":[NSNumber numberWithInt:103717147],
                             @"name":@"依然",
                             @"headImage":@"yr1",
                             @"loaction":@"美国",
                             @"contentString":@"北京市朝阳区重点毕业，目前就读于哈佛MBI，会四种语言",
                             @"isOpen":[NSNumber numberWithBool:NO],
                             @"comments":@[]
                             },
                           @{@"uid":[NSNumber numberWithInt:139496775],
                             @"name":@"cool",
                             @"headImage":@"cool1",
                             @"loaction":@"艾欧尼亚",
                             @"contentString":@"瓦罗兰大陆重点，目前就读于德玛西亚，会5种语言",
                             @"isOpen":[NSNumber numberWithBool:NO],
                             @"comments":@[]
                             },@{@"uid":[NSNumber numberWithInt:137732173],
                                 @"name":@"朵拉",
                                 @"headImage":@"duo1",
                                 @"loaction":@"日本 东京",
                                 @"contentString":@"上海杨浦市重点毕业，目前在日本东京读大一，会三种语言",
                                 @"isOpen":[NSNumber numberWithBool:NO],
                                 @"comments":@[]
                                 },
                           @{@"uid":[NSNumber numberWithInt:103717147],
                             @"name":@"依然",
                             @"headImage":@"yr1",
                             @"loaction":@"美国",
                             @"contentString":@"北京市朝阳区重点毕业，目前就读于哈佛MBI，会四种语言",
                             @"isOpen":[NSNumber numberWithBool:NO],
                             @"comments":@[]
                             },
                           @{@"uid":[NSNumber numberWithInt:139496775],
                             @"name":@"cool",
                             @"headImage":@"cool1",
                             @"loaction":@"艾欧尼亚",
                             @"contentString":@"瓦罗兰大陆重点，目前就读于德玛西亚，会5种语言",
                             @"isOpen":[NSNumber numberWithBool:NO],
                             @"comments":@[]
                             },@{@"uid":[NSNumber numberWithInt:137732173],
                                 @"name":@"朵拉",
                                 @"headImage":@"duo1",
                                 @"loaction":@"日本 东京",
                                 @"contentString":@"上海杨浦市重点毕业，目前在日本东京读大一，会三种语言",
                                 @"isOpen":[NSNumber numberWithBool:NO],
                                 @"comments":@[]
                                 },
                           @{@"uid":[NSNumber numberWithInt:103717147],
                             @"name":@"依然",
                             @"headImage":@"yr1",
                             @"loaction":@"美国",
                             @"contentString":@"北京市朝阳区重点毕业，目前就读于哈佛MBI，会四种语言",
                             @"isOpen":[NSNumber numberWithBool:NO],
                             @"comments":@[]
                             },
                           @{@"uid":[NSNumber numberWithInt:139496775],
                             @"name":@"cool",
                             @"headImage":@"cool1",
                             @"loaction":@"艾欧尼亚",
                             @"contentString":@"瓦罗兰大陆重点，目前就读于德玛西亚，会5种语言",
                             @"isOpen":[NSNumber numberWithBool:NO],
                             @"comments":@[]
                             },@{@"uid":[NSNumber numberWithInt:137732173],
                                 @"name":@"朵拉",
                                 @"headImage":@"duo1",
                                 @"loaction":@"日本 东京",
                                 @"contentString":@"上海杨浦市重点毕业，目前在日本东京读大一，会三种语言",
                                 @"isOpen":[NSNumber numberWithBool:NO],
                                 @"comments":@[]
                                 },
                           @{@"uid":[NSNumber numberWithInt:103717147],
                             @"name":@"依然",
                             @"headImage":@"yr1",
                             @"loaction":@"美国",
                             @"contentString":@"北京市朝阳区重点毕业，目前就读于哈佛MBI，会四种语言",
                             @"isOpen":[NSNumber numberWithBool:NO],
                             @"comments":@[]
                             },
                           @{@"uid":[NSNumber numberWithInt:139496775],
                             @"name":@"cool",
                             @"headImage":@"cool1",
                             @"loaction":@"艾欧尼亚",
                             @"contentString":@"瓦罗兰大陆重点，目前就读于德玛西亚，会5种语言",
                             @"isOpen":[NSNumber numberWithBool:NO],
                             @"comments":@[]
                             }, nil];
    _dataArray = [NSMutableArray array];
    for (int i = 0; i < soursArray.count; i++) {
        MyTableViewModel *myTableViewModel = [[MyTableViewModel alloc] initWithDic:[soursArray objectAtIndex:i]];
        [_dataArray addObject:myTableViewModel];
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [_myTableView.mj_header beginRefreshing];
}

- (void)initTableView
{
    _myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.separatorColor = [UIColor grayColor];
    [_myTableView registerClass:[MyTableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_myTableView];
  
  _myTableView.estimatedRowHeight = 0;
  _myTableView.estimatedSectionFooterHeight = 0;
  _myTableView.estimatedSectionHeaderHeight = 0;
    
    _myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        sleep(3);
        [_myTableView.mj_header endRefreshing];
        [_myTableView reloadData];
    }];
  MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)_myTableView.mj_header;
  header.lastUpdatedTimeLabel.hidden = YES;
  header.stateLabel.hidden = YES;
  
    
    _myTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        sleep(2);
        [_myTableView.mj_footer endRefreshing];
        [_myTableView reloadData];
    }];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyTableViewModel *myModel = [self.dataArray objectAtIndex:indexPath.row];
    CGSize contentSize = [self getStringSizeForStr:myModel.contentString ForFont:17 cmSize:CGSizeMake(ScreenWidth - 65, 1000)];
    CGFloat height = 0;
    for (int i = 0; i < myModel.comments.count; i++) {

        CGSize strSize = [self contentString:[myModel.comments objectAtIndex:i] cmFontSize:[UIFont systemFontOfSize:12.0] cmSize:CGSizeMake(250, 1000)];
        
        height = height + strSize.height + 10;
    }
    
    if (myModel.isOpen) {
        height = height + 45.0 + contentSize.height;
    } else {
        height = height + 45.0 + contentSize.height;
    }
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.myTableViewModel = [_dataArray objectAtIndex:indexPath.row];
    cell.myTableViewModel.cellIndex = indexPath;
    cell.delegate = self;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.textField.isFirstResponder) {
        [self.textField resignFirstResponder];
    }
}

- (void)myTabelViewDelegateLeaveMessage:(MyTableViewModel *)myModel ForPlaceholderStr:(NSString *)str
{
    self.myTableViewModel = myModel;
    
    if (![self.textField resignFirstResponder]) {
        self.textField.placeholder = str;
        [self.textField becomeFirstResponder];
        if ([str isEqualToString:@"留言:"]) {
            self.contentType = ContentTypeOne;
        } else {
            self.contentType = ContenTypeTow;
        }
        
    } else {
    }
}

- (void)keyboardDidShow:(NSNotification *)notify
{
    NSDictionary *dic = notify.userInfo;
    CGRect keyboardRect = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self setTextFieldFrame:keyboardRect forIsHide:NO];
}
- (void)keyboardDidHide:(NSNotification *)notify
{
    NSDictionary *dic = notify.userInfo;
    CGRect keyboardRect = [[dic objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self setTextFieldFrame:keyboardRect forIsHide:YES];
}

- (void)setTextFieldFrame:(CGRect)keyRect forIsHide:(BOOL)ishide
{
    NSLog(@"\n keyboradIshide = %d\n keyY = %f\n keyH = %f", ishide, keyRect.origin.y, keyRect.size.height);

    CGFloat keyHeight = keyRect.size.height;
    if (keyHeight < 1.0) {
        return;
    }
    
    if (ishide) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.textField.frame = CGRectMake(0, ScreenHeight - 40, ScreenWidth, 40);
        } completion:^(BOOL finished) {
        }];
    } else {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.textField.frame = CGRectMake(0, ScreenHeight - keyHeight - 40, ScreenWidth, 40);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _textField) {
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"placeholder = %@", textField.placeholder);
    NSString *str = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (str.length > 0) {
        if (self.contentType == ContentTypeOne) {
            str = [@"ydd:" stringByAppendingString:str];
        } else {
            str = [@"张三回复ydd:" stringByAppendingString:str];
        }
        NSMutableArray *mtbArray = [NSMutableArray arrayWithArray:self.myTableViewModel.comments];
        [mtbArray addObject:str];
        self.myTableViewModel.comments = mtbArray;
        [self.dataArray replaceObjectAtIndex:self.myTableViewModel.cellIndex.row withObject:self.myTableViewModel];
        [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:self.myTableViewModel.cellIndex.row inSection:self.myTableViewModel.cellIndex.section], nil] withRowAnimation:UITableViewRowAnimationNone];
        [self.myTableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionNone animated:YES];
        self.textField.text = nil;
        [self.textField resignFirstResponder];
        return YES;
    } else {
        return NO;
    }
}


- (CGSize)getStringSizeForStr:(NSString *)str ForFont:(CGFloat)fontValue cmSize:(CGSize)cmSize
{
    CGSize strSize;
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:fontValue]};
    strSize = [str boundingRectWithSize:cmSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return strSize;
}

#pragma mark 自适应调整宽度和高度
- (CGSize)contentString:(NSString *)textString cmFontSize:(UIFont *)cmFontSize cmSize:(CGSize)cmSize {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:cmFontSize, NSParagraphStyleAttributeName:paragraphStyle};
    CGRect rect = [textString boundingRectWithSize:cmSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    CGSize labelSize = CGSizeMake(rect.size.width, rect.size.height);
    if (labelSize.height <= 0 || labelSize.width <= 0) {
        labelSize.height = 20;
        labelSize.width = 100;
    }
    return labelSize;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
