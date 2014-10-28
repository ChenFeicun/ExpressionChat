//
//  NotifyMsg.h
//  ExpressionChat
//
//  Created by Feicun on 14-10-14.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NotifyMsg : NSManagedObject

@property (nonatomic, retain) NSString * fromid;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * resid;
@property (nonatomic, retain) NSString * xratio;

@end
