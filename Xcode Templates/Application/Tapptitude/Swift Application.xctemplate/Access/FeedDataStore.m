//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

#import "FeedDataStore.h"
#import <Tapptitude/TTPaginatedDataFeed.h>
#import <Tapptitude/TTFetchedDataSource.h>
#import <Tapptitude/TTSectionedDataSource.h>
#import "API.h"

@interface FeedDataStore ()

@property (nonatomic, strong) NSMutableDictionary *dataSources;

@end

@implementation FeedDataStore

//- (id<TTDataSource>)placesDataSource {
//    NSString *dataSourceID = NSStringFormat(@"%s_", __PRETTY_FUNCTION__);
//    return [self getFeedWithID:dataSourceID orCreateWithBlock:^id<TTDataSource> {
//        
//        TTFetchedDataSource *dataSource = [[TTFetchedDataSource alloc] initWithFetchRequest:self.placesFetchRequest sectionKeyPath:nil context:[NSManagedObjectContext MR_defaultContext]];
//        TTPaginatedDataFeed *dataFeed = [[TTPaginatedDataFeed alloc] init];
//        dataFeed.limit = 500;
//        dataFeed.enableLoadMoreOnlyForCompletePage = YES;
//
//        [dataFeed setLoadFeedPageOperation:^NSOperation *(NSInteger offset, NSInteger limit, void (^callback)(NSArray *content, NSError *error)) {
//            return [APAPI getPlacesWithCallback:callback];
//        }];
//        
//        dataSource.feed = dataFeed;
//        return dataSource;
//    }];
//}
//
//- (id<TTDataSource>)parkingHistoryDataSource {
//	NSString *dataSourceID = NSStringFormat(@"%s_", __PRETTY_FUNCTION__);
//    return [self getFeedWithID:dataSourceID orCreateWithBlock:^id<TTDataSource>{
//        NSFetchRequest *fetchReqeust = [APFeedDataStore pakingsFetchRequest];
//        NSManagedObjectContext *context  = [NSManagedObjectContext MR_defaultContext];
//        TTFetchedDataSource *dataSource = [[TTFetchedDataSource alloc] initWithFetchRequest:fetchReqeust sectionKeyPath:@"sectionName" context:context];
//        
//        TTPaginatedDataFeed *feed = [[TTPaginatedDataFeed alloc] init];
//        feed.limit = 20;
//        feed.enableLoadMoreOnlyForCompletePage = YES;
//        [feed setLoadFeedPageOperation:^NSOperation *(NSInteger offset, NSInteger limit, void (^callback)(NSArray *content, NSError *error)) {
//            return [APAPI getParkingHistoryWithOffset:offset limit:limit callback:callback];
//        }];
//        dataSource.feed = feed;
//        
//        return dataSource;
//    }];
//}

#pragma mark - Fetch requests

//+ (NSFetchRequest *)pakingsFetchRequest {
//    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:[NSEntityDescription entityForName:@"APParking" inManagedObjectContext:context]];
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:NO];
//    fetchRequest.sortDescriptors = @[ sortDescriptor ];
//    fetchRequest.fetchBatchSize = 50;
//    fetchRequest.includesSubentities = NO;
//    return fetchRequest;
//}
//
//- (NSFetchRequest *)placesFetchRequest {
//    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    [fetchRequest setEntity:[NSEntityDescription entityForName:@"APPlace" inManagedObjectContext:context]];
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"canPark == YES"];
//    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"area.name" ascending:YES];
//    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
//    fetchRequest.sortDescriptors = @[sortDescriptor1, sortDescriptor2];
//    fetchRequest.fetchBatchSize = 50;
//    fetchRequest.includesSubentities = NO;
//    return fetchRequest;
//}

#pragma mark - Helpers

- (id<TTDataSource>)getFeedWithID:(NSString *)feedID orCreateWithBlock:(id<TTDataSource>(^)())createBlock {
    id<TTDataSource> dataSource = [self.dataSources valueForKey:feedID];
    if (! dataSource) {
        dataSource = createBlock();
        dataSource.dataSourceID = feedID;
        [self.dataSources setValue:dataSource forKey:feedID];
    }
    
    return dataSource;
}

@end
