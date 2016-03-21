//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import "___FILEBASENAME___Cell.h"
#import "___FILEBASENAME___Downloader.h"
#import "ErrorDisplay.h"

@implementation ___FILEBASENAME___Cell

- (void)setFileDownloader:(___FILEBASENAME___Downloader *)fileDownloader {
    [_fileDownloader removeObserver:self forKeyPath:@"progress"];
    [_fileDownloader removeObserver:self forKeyPath:@"error"];
    _fileDownloader = fileDownloader;
    [_fileDownloader addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionOld context:nil];
    [_fileDownloader addObserver:self forKeyPath:@"error" options:NSKeyValueObservingOptionOld context:nil];
    self.downloadView.hidden = fileDownloader == nil;
    self.downloadProgress.progress = fileDownloader.progress;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"error"]) {
        NSError *error = ((___FILEBASENAME___Downloader *)object).error;
        if (error) {
            [ErrorDisplay showErrorWithTitle:@"Network Error" message:@"Please check your internet connection and try again"];
            self.fileDownloader = nil;
        }
    }
    if ([keyPath isEqualToString:@"progress"]) {
        float progress = ((___FILEBASENAME___Downloader *)object).progress;
        [self.downloadProgress setProgress:progress animated:YES];
        if (progress == 1.0f) {
            self.fileDownloader = nil;
            self.downloadedImageView.hidden = NO;
        }
    }
}

- (void)dealloc {
    self.fileDownloader = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [[UIColor colorWithWhite:0.7 alpha:0.3] CGColor];
}

@end
