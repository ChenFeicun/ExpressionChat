//
//  NotifyMsg.h
//  ExpressionChat
//
//  Created by Feicun on 15/1/5.
//  Copyright (c) 2015年 Feicun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NotifyMsg : NSManagedObject

@property (nonatomic, retain) NSString * audioid;
@property (nonatomic, retain) NSString * audioname;
@property (nonatomic, retain) NSString * audiourl;
@property (nonatomic, retain) NSString * fromid;
@property (nonatomic, retain) NSString * resname;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * xratio;

@end
