//
//  JDAddressView.h
//  111
//
//  Created by LX on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JDAddressViewDelegate <NSObject>

- (void)didSelected:(NSString *)address;

@end

@interface JDAddressView : UIView

@property (nonatomic, weak) id<JDAddressViewDelegate>delegate;

@end
