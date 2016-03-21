//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import <Foundation/Foundation.h>
#import "___FILEBASENAME___Downloader.h"

@interface Offline___FILEBASENAME___s : NSObject <FileDownloaderDelegate>

+ (instancetype)sharedInstance;
- (___FILEBASENAME___Downloader *)fileDownloaderForFile:(id<FileModel>)file;
- (___FILEBASENAME___Downloader *)startFileDownloaderForFile:(id<FileModel>)file;
- (void)cancelFileDownloaderForFile:(id<FileModel>)file;
- (BOOL)isFileInProgress:(id<FileModel>)file;

@end
