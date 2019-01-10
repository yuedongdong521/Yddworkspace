//
//  TestKVOViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/1/10.
//  Copyright © 2019 QH. All rights reserved.
//

#import "TestKVOViewController.h"
#import "TestKVOModel.h"

@interface TestKVOViewController ()

@property(nonatomic, strong) TestKVOModel * model;

@end

@implementation TestKVOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.view.backgroundColor = [UIColor whiteColor];
  self.model = [[TestKVOModel alloc] init];
  
  [self.model addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
  
  self.model.name = @". 赋值";
  [self.model setName:@"set 赋值"];
  [self.model setValue:@"kvc" forKey:@"name"];
  [self.model changeName:@"-"];
  
  NSMutableString *str = [NSMutableString stringWithFormat:@"123"];
  self.model.contentStr = str;
  [str appendFormat:@"4"];
  NSLog(@"contentStr = %@", self.model.contentStr);
  
  TestKVOModel *model1 = [[TestKVOModel alloc] init];
  model1.name = @"model1";
  TestKVOModel *model2 = [[TestKVOModel alloc] init];
  model2.name = @"model2";
  NSMutableArray *array = [NSMutableArray arrayWithArray:@[model1, model2]];
  NSArray *array1 = [[NSArray alloc] initWithArray:array copyItems:YES];
  [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    ((TestKVOModel *)obj).name = [NSString stringWithFormat:@"model_%lu", (unsigned long)idx];
  }];
  
  [array1 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSLog(@"name %@", ((TestKVOModel *)obj).name);
  }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
  if ([keyPath isEqualToString:@"name"]) {
    NSString *oldName = change[NSKeyValueChangeOldKey];
    NSString *newName = change[NSKeyValueChangeNewKey];
    NSLog(@"oldName = %@, newName = %@", oldName, newName);
  }
}

- (void)dealloc
{
  [self.model removeObserver:self forKeyPath:@"name"];
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
