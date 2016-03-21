//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ___FILEBASENAME___Downloader;

@protocol FileModel <NSObject>

@property (nonatomic, strong) NSURL *downloadURL;
@property (nonatomic, strong) NSString *name;

@optional
@property (nonatomic, strong) NSURL *coverURL;

@end

@protocol FileDownloaderDelegate <NSObject>

- (void)fileDownloaderDidStartDownload:(___FILEBASENAME___Downloader *)fileDownloader;
- (void)fileDownloaderDidFinishDownload:(___FILEBASENAME___Downloader *)fileDownloader;
- (void)fileDownloader:(___FILEBASENAME___Downloader *)fileDownloader didFailDownloadWithError:(NSError *)error;

@end

@interface ___FILEBASENAME___Downloader : NSObject

@property (nonatomic, strong) id<FileModel> file;
@property (nonatomic, assign) CGFloat progress; //download is finished when progress == 1
@property (nonatomic, weak) id<FileDownloaderDelegate> delegate;
@property (nonatomic, strong) NSError *error; //download error to be observed

- (instancetype)initWithFile:(id<FileModel>)file;
- (void)startDownload;
- (void)cancelDownload;

@end
