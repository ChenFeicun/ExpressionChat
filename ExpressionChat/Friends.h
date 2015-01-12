//
//  Friends.h
//  ExpressionChat
//
//  Created by Feicun on 15/1/7.
//  Copyright (c) 2015年 Feicun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friends : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * unread;

@end
