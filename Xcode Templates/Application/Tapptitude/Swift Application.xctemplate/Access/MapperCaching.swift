//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import ObjectMapper

/// Simple json caching storage, where each model is translated into json before saving
/// or viceversa
struct MapperCaching<T> {
    static var rootDirectory: String {
        return "Mapper"
    }
    
    static var relativePath: NSString {
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as NSString
        return dirPath.appendingPathComponent(MapperCaching.rootDirectory) as NSString
    }
    
    init(resourceID: String) {
        self.filePath = MapperCaching.relativePath.appendingPathComponent(resourceID).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
    }
    
    var filePath: String!
    var fileName: String {
        return (filePath as NSString).lastPathComponent
    }
    
    fileprivate func save(jsonConvertor: @escaping () -> Any) {
        do {
            let jsonObject = jsonConvertor()
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            try self.saveToFile(data: jsonData)
        }  catch let error as NSError {
            print("MapperCaching: ERROR saving: \(error)")
        }
    }
    
    static func deleteCachingDirectory() {
        let path = MapperCaching.relativePath
        do {
            try FileManager.default.removeItem(atPath: path as String)
        } catch let error as NSError {
            print("MapperCaching: Failed to delete file \(path)\n\(error)")
        }
    }
}

extension MapperCaching where T: Mappable {
    /// load json file from disk and tranlate into an mappable object
    func loadFromFile() -> T? {
        let path = filePath as String
        print("MapperCaching: Loading \(fileName) from file... \(String(describing: T.self))")
        
        do {
            let jsonString = try loadContentFromFile()
            let parsedJSON = Mapper<T>.parseJSONString(JSONString: jsonString ?? "")
            return Mapper<T>().map(JSONObject: parsedJSON)
        } catch let error as NSError {
            print("Failed to load JSON \(path)\n\(error)")
        }
        
        return nil
    }
    
    
    /// will save object as json file on disk
    /// - on nil --> file is deleted
    func saveToFile(_ object: T?){
        if let object = object {
            print("MapperCaching: Saving \'\(fileName)\' (\(object)) to file...")
            DispatchQueue.global(qos: .background).async {
                self.save(jsonConvertor: { object.toJSON() })
            }
        } else {
            removeFile(path: filePath)
        }
    }
}

extension MapperCaching where T: Sequence, T.Iterator.Element: Mappable {
    
    /// load json file from disk and tranlate into an mappable object
    func loadFromFile() -> [T.Iterator.Element]? {
        let path = filePath as String
        print("MapperCaching: Loading \(fileName) from file...")
        
        do {
            let jsonString = try loadContentFromFile()
            let parsedJSON = Mapper<T.Iterator.Element>.parseJSONString(JSONString: jsonString ?? "")
            return Mapper<T.Iterator.Element>().mapArray(JSONObject: parsedJSON)
        } catch let error as NSError {
            print("MapperCaching: Failed to load JSON \(path)\n\(error)")
        }
        
        return nil
    }
    
    /// will save object as json file on disk
    /// - on nil --> file is deleted
    func saveToFile(_ object: [T.Iterator.Element]?){
        if let object = object {
            print("MapperCaching: Saving \'\(fileName)\' to file...")
            DispatchQueue.global(qos: .background).async {
                self.save(jsonConvertor: { object.toJSON() })
            }
        } else {
            removeFile(path: filePath)
        }
    }
}


extension MapperCaching {
    fileprivate func loadContentFromFile() throws -> String? {
        if FileManager.default.fileExists(atPath: filePath) == false {
            return nil
        }
        
        return try String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
    }
    
    fileprivate func saveToFile(data: Data) throws {
        // Create directory if necessary
        let fileManager = FileManager.default
        let filePath = self.filePath as NSString
        if fileManager.fileExists(atPath: filePath.deletingLastPathComponent) == false {
            try fileManager.createDirectory(atPath: filePath.deletingLastPathComponent, withIntermediateDirectories: false, attributes: nil)
        }
        
        // write data
        try data.write(to: URL(fileURLWithPath: self.filePath))
    }
    
    fileprivate func removeFile(path: String) {
        do {
            try FileManager.default.removeItem(atPath: path as String)
        } catch let error as NSError {
            print("MapperCaching: Failed to delete file \(path)\n\(error)")
        }
    }
}
