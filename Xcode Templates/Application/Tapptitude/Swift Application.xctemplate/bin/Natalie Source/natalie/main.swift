//
//  main.swift
//  natalie
//
//  Created by Alexandru Tudose on 09/11/2016.
//  Copyright © 2016 Tapptitude. All rights reserved.
//

import Foundation

if Process.arguments.count == 1 {
    print("Invalid usage. Missing path to storyboard.")
    exit(1)
}

let argument = Process.arguments[1]
var filePaths:[String] = []
let storyboardSuffix = ".storyboard"
if argument.hasSuffix(storyboardSuffix) {
    filePaths = [argument]
} else if let s = findStoryboards(argument, suffix: storyboardSuffix) {
    filePaths = s
}
let storyboardFiles = filePaths.map { StoryboardFile(filePath: $0) }

for os in OS.allValues {
    let storyboardsForOS = storyboardFiles.filter({ $0.storyboard.os == os })
    if !storyboardsForOS.isEmpty {
        
        if storyboardsForOS.count != storyboardFiles.count {
            print("#if os(\(os.rawValue))")
        }
        
        processStoryboards(storyboardsForOS, os: os)
        
        if storyboardsForOS.count != storyboardFiles.count {
            print("#endif")
        }
    }
}

exit(0)
