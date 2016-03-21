//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "___FILEBASENAMEASIDENTIFIER___.h"

@interface ___FILEBASENAMEASIDENTIFIER___Parser : NSObject

+ (NSArray *)parseItems:(NSArray *)items inContext:localContext;
+ (___FILEBASENAMEASIDENTIFIER___ *)parseItem:(NSDictionary *)item inContext:localContext;

@end