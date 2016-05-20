//: [Previous](@previous)

import UIKit
import Tapptitude

//public class CachedJSONDataSource: DataSource {
//    public override func dataFeed(dataFeed: TTDataFeed?, didReloadContent content: [Any]?) {
//        
//        super.dataFeed(dataFeed, didReloadContent: content)
//    }
//    
//    public override func dataFeed(dataFeed: TTDataFeed?, didLoadMoreContent content: [Any]?) {
//        
//        super.dataFeed(dataFeed, didReloadContent: content)
//    }
//    
//    public override var dataSourceID: String? {
//        didSet {
//            loadCachedContent()
//        }
//    }
//    
//    
//    public func loadCachedContent() {
//        if dataSourceID?.isEmpty == true {
//            return
//        }
////        
////        NSString *filePath = [self jsonCachePath];
////        
////        NSError *error = nil;
////        NSData *data = [NSData dataWithContentsOfFile:filePath options:0 error:&error];
////        if (data) {
////            id content = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
////            if ([content isKindOfClass:[NSArray class]]) {
////                [self setValue:[content mutableCopy] forKey:@"content"];
////            } else {
////                TTLogExpr(error);
////            }
////        } else {
////            TTLogExpr(error);
////        }
//    }
//    
//    public var jsonCachePath: String {
//        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).last!
//        let fileName = self.dataSourceID?.stringByReplacingOccurrencesOfString("/", withString: "_")
//        let filePath =  cachePath + "/" + fileName! + ".JSON";
//        return filePath
//    }
//    
//    public func saveContentToJSONFile () {
//        if dataSourceID?.isEmpty == true {
//            return
//        }
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { in
//            let filePath = self.jsonCachePath
//            
//            if self.content.count > 0 {
//                let data = try? NSJSONSerialization.dataWithJSONObject(self.content, options: .PrettyPrinted) dataWithJSONObject:self.content options:0 error:&error];
//                if (data) {
//                    [data writeToFile:filePath atomically:NO];
//                } else {
//                    TTLogExpr(error);
//                }
//            } else {
//                try? NSFileManager.defaultManager().removeItemAtPath(filePath)
//            }
//        })
//    }
//    
//    func saveJSONObject(jsonObject: AnyObject) {
//        let filePath = self.jsonCachePath as NSString
//        
//        if NSJSONSerialization.isValidJSONObject(jsonObject) {
//            do {
//                let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonObject, options: NSJSONWritingOptions.PrettyPrinted)
//                let string = NSString(data: jsonData, encoding: NSUTF8StringEncoding)
//                
//                // Create directory if necessary
//                let fileManager = NSFileManager.defaultManager()
//                if fileManager.fileExistsAtPath(filePath.stringByDeletingLastPathComponent) == false {
//                    try fileManager.createDirectoryAtPath(filePath.stringByDeletingLastPathComponent, withIntermediateDirectories: false, attributes: nil)
//                }
//                
//                // write data
//                let path = filePath as String
//                if let string = string {
//                    try string.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
//                    print(String(self) + ": Saved file successfully")
//                }
//            } catch let error as NSError {
//                print(String(self) + ": ERROR writing file: \(error)")
//            }
//            
//            
//        } else {
//            print(String(self) + ": ERROR: couldn't save to file...")
//        }
//    }
//    
//}

//: [Next](@next)
