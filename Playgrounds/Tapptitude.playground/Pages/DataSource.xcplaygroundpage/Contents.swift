//: [Previous](@previous)

import Foundation
import Tapptitude

let testDataSource = DataSource<Any>(["23", 3])
testDataSource.remove ({ ($0 as? String) == "23" })
let items: [Int] = [23, 5]
testDataSource.append(contentsOf: items)
let nr: Int = 12312
testDataSource.append(nr)
testDataSource.remove({$0 as? Int == nr})

var dataSource = DataSource([2, 4, 6])
print(dataSource.content)
dataSource[0]
dataSource[2] = 8
dataSource[1, 1]
dataSource.remove({$0 == nr})
print(dataSource)

dataSource += [12]
dataSource.remove({$0 == 2})

let secondDataSource = DataSource([1, 2, 3])
dataSource += secondDataSource
print(dataSource.content)

let content:[String] = dataSource.map({ "-" + String($0) })
print(content)
dataSource.contains(12)
dataSource.count
dataSource.first
dataSource.last

dataSource.remove ({ $0 == 2 })
print(dataSource.content)

dataSource.insert(contentsOf: [1, 2, 3, 4], at: IndexPath(item: 2, section: 0))
print(dataSource.content)

dataSource.insert(contentsOf: [], at: IndexPath(item: 2, section: 0))
print(dataSource.content)

dataSource.append(contentsOf: [123])
print(dataSource.content)

dataSource.remove({ _ in return true })
print(dataSource.content)

dataSource.isEmpty

var nilDataSource: DataSource<Int>? = DataSource([1, 2, 3])
nilDataSource?.isEmpty == true
nilDataSource?.isEmpty == false

nilDataSource = nil
nilDataSource?.isEmpty == true
nilDataSource?.isEmpty == false

//: [Next](@next)

let newDataSource = DataSource([1]).dropLast()
 newDataSource.contains(1)
let joined = DataSource(["12312", "ABCD"]).joined(separator: " ")


let sectionDataSource = SectionedDataSource([["Maria", "Ion"], ["Ghita"]])
sectionDataSource.sectionHeaders = ["23", 323]
