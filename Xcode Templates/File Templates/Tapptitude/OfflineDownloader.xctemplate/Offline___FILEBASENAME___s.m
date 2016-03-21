//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "Offline___FILEBASENAME___s.h"

@interface Offline___FILEBASENAME___s ()

@property (nonatomic, strong) NSMutableDictionary *filesDict;

@end

@implementation Offline___FILEBASENAME___s

#pragma mark - Lifecycle

static Offline___FILEBASENAME___s *offlinePublications = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        offlinePublications = [[Offline___FILEBASENAME___s alloc] init];
    });
    return offlinePublications;
}

#pragma mark - Getters and Setters

- (NSMutableDictionary *)filesDict {
    if (!_filesDict) {
        _filesDict = [NSMutableDictionary dictionary];
    }
    return _filesDict;
}

#pragma mark - Instance methods

- (BOOL)isFileInProgress:(id<FileModel>)file {
    return self.filesDict[file.name] != nil;
}

- (___FILEBASENAME___Downloader *)fileDownloaderForFile:(id<FileModel>)file {
    ___FILEBASENAME___Downloader *fileDownloader = self.filesDict[file.name];
    return fileDownloader;
}

- (___FILEBASENAME___Downloader *)startFileDownloaderForFile:(id<FileModel>)file {
    ___FILEBASENAME___Downloader *fileDownloader = self.filesDict[file.name];
    if (!fileDownloader) {
        fileDownloader = [[___FILEBASENAME___Downloader alloc] initWithFile:file];
        fileDownloader.delegate = self;
        [fileDownloader startDownload];
    }
    return fileDownloader;
}

- (void)cancelFileDownloaderForFile:(id<FileModel>)file {
    ___FILEBASENAME___Downloader *fileDownloader = self.filesDict[file.name];
    if (fileDownloader) {
        [self.filesDict removeObjectForKey:file.name];
        [fileDownloader cancelDownload];
    }
}

#pragma mark - PublicationDownloaderDelegate

- (void)fileDownloaderDidStartDownload:(___FILEBASENAME___Downloader *)fileDownloader {
    [self.filesDict setObject:fileDownloader forKey:fileDownloader.file.name];
}

- (void)fileDownloaderDidFinishDownload:(___FILEBASENAME___Downloader *)fileDownloader {
    [self.filesDict removeObjectForKey:fileDownloader.file.name];
}

- (void)fileDownloader:(___FILEBASENAME___Downloader *)fileDownloader didFailDownloadWithError:(NSError *)error {
    [self.filesDict removeObjectForKey:fileDownloader.file.name];
}

@end
