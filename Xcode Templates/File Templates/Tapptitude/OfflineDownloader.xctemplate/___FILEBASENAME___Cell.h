//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

#import <UIKit/UIKit.h>
#import "___FILEBASENAME___Downloader.h"

@interface ___FILEBASENAME___Cell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *downloadedImageView;
@property (weak, nonatomic) IBOutlet UIView *downloadView;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgress;

@property (nonatomic, strong) ___FILEBASENAME___Downloader *fileDownloader;
@property (nonatomic, strong) id<FileModel> file;

@end
