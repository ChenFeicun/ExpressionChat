//
//  Friends.h
//  ExpressionChat
//
//  Created by Feicun on 14-10-9.
//  Copyright (c) 2014年 Feicun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friends : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * account;

@end
