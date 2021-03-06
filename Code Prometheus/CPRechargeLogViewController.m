//
//  CPRechargeViewController.m
//  Code Prometheus
//
//  Created by mirror on 13-12-30.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPRechargeLogViewController.h"
#import <MBProgressHUD.h>
#import <TWMessageBarManager.h>

@interface CPRechargeInfo : NSObject
@property(nonatomic) NSNumber* price;
@property(nonatomic) NSString* amount;
@property(nonatomic) NSString* updateDate;
@end
@implementation CPRechargeInfo
@end

@interface CPRechargeLogViewController ()
// 脏数据,是否需要刷新
@property (nonatomic) BOOL dirty;
@property (nonatomic) NSArray* rechargeInfoArray;
@end

@implementation CPRechargeLogViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dirty = YES;
    self.navigationItem.title = @"充值记录";
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.dirty) {
        [self requestRechargeLog];
        self.dirty = NO;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rechargeInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"rechargeLog";
    static NSInteger const viewTag1 = 10001;
    static NSInteger const viewTag2 = 10002;
    static NSInteger const viewTag3 = 10003;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    CPRechargeInfo* rechargeInfo = self.rechargeInfoArray[indexPath.row];
    UILabel* priceLabel = (UILabel*)[cell viewWithTag:viewTag1];
    priceLabel.text = [NSString stringWithFormat:@"%d¥",[rechargeInfo.price integerValue]/100];
    UILabel* amountLabel = (UILabel*)[cell viewWithTag:viewTag2];
    amountLabel.text = [NSString stringWithFormat:@"%@豆",rechargeInfo.amount];
    UILabel* updateDateLabel = (UILabel*)[cell viewWithTag:viewTag3];
    updateDateLabel.text = rechargeInfo.updateDate;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - private
-(void) requestRechargeLog{
    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
	[self.view addSubview:hud];
    [hud show:YES];
    [CPServer requestRechargeInfo:^(BOOL success, NSString *message, NSMutableArray *results) {
        if (success) {
            NSMutableArray* rechargeInfos = [NSMutableArray array];
            for (NSDictionary* dic in results) {
                CPRechargeInfo* rechargeInfo = [CPRechargeInfo new];
                rechargeInfo.price = [dic objectForKey:@"price"];
                rechargeInfo.amount = [dic objectForKey:@"amount"];
                rechargeInfo.updateDate = [dic objectForKey:@"updateDate"];
                [rechargeInfos addObject:rechargeInfo];
            }
            self.rechargeInfoArray = [NSArray arrayWithArray:rechargeInfos];
            [self.tableView reloadData];
        }else{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"NO"
                                                           description:message
                                                                  type:TWMessageBarMessageTypeError];
        }
        [hud hide:YES];
    }];
}
@end
