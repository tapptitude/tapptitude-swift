//: [Previous](@previous)

import Foundation
import Tapptitude

var dataSource = DataSource([2, 4, 6])
print(dataSource.content)
dataSource[0]
dataSource[2] = 8
dataSource[1, 1]
print(dataSource)

dataSource += [12]

let secondDataSource = DataSource([1, 2, 3])
dataSource += secondDataSource
print(dataSource.content)

dataSource.removeWith { (item) -> Bool in
    return (item as? Int) == 2
}
print(dataSource.content)


//: [Next](@next)
