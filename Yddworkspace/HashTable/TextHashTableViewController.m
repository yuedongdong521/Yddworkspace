//
//  TextHashTableViewController.m
//  Yddworkspace
//
//  Created by ydd on 2019/5/13.
//  Copyright © 2019 QH. All rights reserved.
//

#import "TextHashTableViewController.h"
#import "HashTable.h"

@interface TextHashTableViewController ()

@end

@implementation TextHashTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *objStr1 = [[UILabel alloc] init];
    
    UILabel *objStr2 = [[UILabel alloc] init];
    
    UILabel *objStr3 = [[UILabel alloc] init];
    
    __weak typeof(objStr1) weakObj1 = objStr1;
    
    HashTable *hash = [HashTable shareHashTable];
    
//    [hash addObjc:objStr1];
    [hash addObjc:objStr2];
    [hash addObjc:objStr3];
    [hash addObjc:weakObj1];
    
    NSLog(@" hash all objc 1 = %@", [hash getHashTableArray]);
    
    objStr1 = nil;
    
     NSLog(@" hash all objc 2 = %@", [hash getHashTableArray]);
    
    objStr2 = nil;
    
     NSLog(@" hash all objc 3 = %@", [hash getHashTableArray]);
    
//    [hash addObjc:objStr3];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         NSLog(@" hash all objc 4 = %@", [hash getHashTableArray]);
    });
    
  
    
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
