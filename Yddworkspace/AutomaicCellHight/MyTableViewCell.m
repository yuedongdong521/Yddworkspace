//
//  MyTableViewCell.m
//  Yddworkspace
//
//  Created by ispeak on 16/10/18.
//  Copyright © 2016年 QH. All rights reserved.
//

#import "MyTableViewCell.h"



@interface MyTableViewCell ()<UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property (nonatomic, retain) UIImageView *headImageView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *contentLabel;
@property (nonatomic, retain) UIButton *tastBtn;

@property (nonatomic, retain) UIView *tableBgView;
@property (nonatomic, retain) UITableView *msgTableView;
@property (nonatomic, retain) UIImageView *msgBgImage;

@end

@implementation MyTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.headImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_headImageView];
        
        self.nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_nameLabel];
        
        self.contentLabel = [[UILabel alloc] init];
        self.contentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.contentLabel];
        
        self.tastBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.tastBtn addTarget:self action:@selector(openTast:) forControlEvents:UIControlEventTouchUpInside];
        [self.tastBtn setImage:[UIImage imageNamed:@"Unknown-1"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.tastBtn];
        
        self.tableBgView = [[UIView alloc] init];
        self.tableBgView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:self.tableBgView];
        
        self.msgTableView = [[UITableView alloc] init];
        self.msgTableView.backgroundColor = [UIColor grayColor];
//        self.msgTableView.separatorStyle = NO;
        self.msgTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.msgTableView.separatorColor = [UIColor clearColor];
        self.msgTableView.scrollEnabled = NO;
        self.msgTableView.delegate = self;
        self.msgTableView.dataSource = self;
        [self.msgTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [self.tableBgView addSubview:_msgTableView];
        
        UIImage *bgImage = [UIImage imageNamed:@"Unknown"];
        bgImage = [bgImage stretchableImageWithLeftCapWidth:18 topCapHeight:10];
        self.msgBgImage = [[UIImageView alloc] init];
        self.msgBgImage.image = bgImage;
        
    }
    return self;
}

- (void)openTast:(id)send
{
    [_delegate myTabelViewDelegateLeaveMessage:_myTableViewModel ForPlaceholderStr:@"留言:"];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.headImageView.frame = CGRectMake(10, 10, 40, 40);
    self.nameLabel.frame = CGRectMake(55, 10, ScreenWidth - 65 - 50, 20);
    self.tastBtn.frame = CGRectMake(ScreenWidth - 40, 0, 30, 40);
//    CGSize contentSize = [self contentString:self.myTableViewModel.contentString cmFontSize:[UIFont systemFontOfSize:17] cmSize:CGSizeMake(self.contentView.bounds.size.width - 65, 20)]; //
    CGSize contentSize = [self getStringSizeForStr:self.myTableViewModel.contentString ForFont:17.0 cmSize:CGSizeMake(ScreenWidth - 65, 1000)];
    self.contentLabel.frame = CGRectMake(55, 35, ScreenWidth - 65, contentSize.height);
    CGFloat tableViewH = 0;
    for (int i = 0; self.myTableViewModel.comments.count > i; i++) {
        NSString *str = [self.myTableViewModel.comments objectAtIndex:i];
        CGSize strSize = [self contentString:str cmFontSize:[UIFont systemFontOfSize:12.0] cmSize:CGSizeMake(250, 1000)];
        tableViewH = tableViewH + strSize.height + 10;
    }
    self.tableBgView.frame = CGRectMake(55, 35 + contentSize.height, ScreenWidth - 65, tableViewH == 0 ? tableViewH: tableViewH + 10);
    
    self.msgBgImage.frame = self.tableBgView.frame;
    CALayer *imageLayer = self.msgBgImage.layer;
    imageLayer.frame = CGRectMake(0, 0, self.tableBgView.frame.size.width, self.tableBgView.frame.size.height);
    self.tableBgView.layer.mask = imageLayer;
    [self.tableBgView setNeedsDisplay];
    
    self.msgTableView.frame = CGRectMake(0, 8, self.contentView.bounds.size.width - 65, tableViewH);
    
}

- (void)setMyTableViewModel:(MyTableViewModel *)myTableViewModel
{
    if (_myTableViewModel != myTableViewModel) {
        _myTableViewModel = myTableViewModel;
    }
    
    _headImageView.image = [UIImage imageNamed:_myTableViewModel.headImage];
    _nameLabel.text = [NSString stringWithFormat:@"呢称:%@", _myTableViewModel.name];
    _contentLabel.text = _myTableViewModel.contentString;
    [self.msgTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string = [self.myTableViewModel.comments objectAtIndex:indexPath.row];
//    CGSize labelSize = [self getStringSizeForStr:string ForFont:12 cmSize:CGSizeMake(250, 1000)];
    CGSize labelSize = [self contentString:string cmFontSize:[UIFont systemFontOfSize:12.0] cmSize:CGSizeMake(250, 1000)];
    return labelSize.height + 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myTableViewModel.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.backgroundColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.numberOfLines = 0;
    NSString *commentStr = [self.myTableViewModel.comments objectAtIndex:indexPath.row];
   
    NSRange rang = [commentStr rangeOfString:@":"];
    
    if (rang.location != NSNotFound) {
        NSString *nameStr = [commentStr substringToIndex:rang.location + rang.length];
        NSMutableAttributedString *attr = [self addAttirbutesString:commentStr name:nameStr color:[UIColor blueColor]];
        cell.textLabel.attributedText = attr;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *comments = [self.myTableViewModel.comments objectAtIndex:indexPath.row];
    NSRange range = [comments rangeOfString:@"张三回复"];
    if (range.location != NSNotFound) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil, nil];
        [sheet showInView:self.window];
    } else {
        [self.delegate myTabelViewDelegateLeaveMessage:self.myTableViewModel ForPlaceholderStr:@"回复:"];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"sheetIndex = %ld", (long)buttonIndex);
    if (buttonIndex == 1) {
        
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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


- (NSMutableAttributedString *)addAttirbutesString:(NSString *)string name:(NSString *)nameStr color:(UIColor *)color
{
    NSMutableAttributedString *mtbAttr = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange rang = [nameStr rangeOfString:@"回复"];
    if (rang.location != NSNotFound) {
        [mtbAttr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, rang.location)];
        [mtbAttr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(rang.length + rang.location, nameStr.length - rang.length - rang.location)];
    } else {
        NSRange nameRang = [string rangeOfString:nameStr];
        if (nameRang.location != NSNotFound) {
            [mtbAttr addAttribute:NSForegroundColorAttributeName value:color range:nameRang];
        }
    }
    return mtbAttr;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
