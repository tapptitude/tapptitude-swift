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

var items = [23, 23]
items.append(23)
print(items)

//: [Next](@next)
