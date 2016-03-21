//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___Downloader.h"
#import <AFNetworking.h>
#import <Tapptitude.h>

@interface ___FILEBASENAME___Downloader ()

@property (nonatomic, strong) AFHTTPRequestOperation *operation;

@end

@implementation ___FILEBASENAME___Downloader

- (instancetype)initWithFile:(id<FileModel>)file {
    self = [super init];
    if (self) {
        self.file = file;
    }
    return self;
}

- (void)startDownload {
    [self downloadPublication:self.file];
    [self.operation start];
    [self.delegate fileDownloaderDidStartDownload:self];
}

- (void)cancelDownload {
    [self.operation cancel];
}

-(void)downloadPublication:(id<FileModel>)file
{
    NSURLRequest *request = [NSURLRequest requestWithURL:file.downloadURL];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    NSString *fileName = file.name;
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    self.operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    @weakify(self);
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        TTLog(@"Successfully downloaded file to %@", path);
        [self copyToDocumentsDirectoryFileNamed:fileName fromPath:path];
        [self.delegate fileDownloaderDidFinishDownload:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        @strongify(self);
        TTLog(@"Error: %@", error);
        self.progress = 0;
        self.error = error;
        [self.delegate fileDownloader:self didFailDownloadWithError:error];
    }];
    [self.operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        @strongify(self);
        TTLog(@"Download = %f", (float)totalBytesRead / totalBytesExpectedToRead);
        self.progress = (float)totalBytesRead / totalBytesExpectedToRead;
    }];
}

- (void)copyToDocumentsDirectoryFileNamed:(NSString *)fileName fromPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *txtPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    if ([fileManager fileExistsAtPath:txtPath] == NO) {
        [fileManager moveItemAtPath:filePath toPath:txtPath error:&error];
    }
    if (!error) {
        TTLog(@"Successfully copied file to %@", txtPath);
    }
}

@end
