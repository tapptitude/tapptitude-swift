//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

#import "___FILEBASENAME___Parser.h"
#import <TTManagedObjectUpdater.h>

@implementation ___FILEBASENAMEASIDENTIFIER___Parser

+ (NSArray *)parseItems:(NSArray *)items inContext:localContext {
    TTManagedObjectUpdater *updater = [___FILEBASENAMEASIDENTIFIER___ objectUpdaterFromObjectsToParse:items fromObjectIDKey:@"<#id#>" intoObjectKey:@"<#toID#>" managedObjectContext:localContext];

//    parse relations
//    NSArray *places = [items valueForKey:@"place"];
//    [APPlaceParser parsePlaces:places inContext:localContext];
//    TTManagedObjectUpdater *placeUpdater = [APPlace objectUpdaterForManagedObjectContext:localContext];
    
    NSMutableArray *parsedItems = [NSMutableArray arrayWithCapacity:items.count];
    for (NSDictionary *dictionary in items) {
        NSString *contentID = [dictionary objectForKey:@"<#id#>"];
        ___FILEBASENAMEASIDENTIFIER___ *info = [updater findOrCreateObjectWithID:contentID];
        
//        info.key = dictionary[@"key"];
//        info.key = dictionary[@"key"];
//        info.key = dictionary[@"key"];
//        info.key = dictionary[@"key"];
        
//        link relation, with parsed item
//        info.place = [placeUpdater findObjectWithID:[dictionary valueForKeyPath:@"place.id"]];
        
        
        [parsedItems addObject:info];
    }
    
    return parsedItems;
}


+ (___FILEBASENAMEASIDENTIFIER___ *)parseItem:(NSDictionary *)item inContext:localContext {
    if (! item) {
        return nil;
    }
    
    return [[self parseItems:@[item] inContext:localContext] firstObject];
}

@end
