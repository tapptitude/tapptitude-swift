# Tapptitude Swift

![alt text](https://img.shields.io/badge/language-Swift_5-orange)
![alt text](https://img.shields.io/badge/platform-iOS-blue)
![alt text](https://img.shields.io/badge/license-MIT-green)


Tapptitude Swift is a Xcode library to speed up iOS development for usual scenario. Dispaying a scrollable list with multiple kinds of cells, handling loading more data for you. Support for empty view and reloading data is also present.

## Installation

[CocoaPods](http://cocoapods.org/) is a dependency manager for Cocoa projects. To integrate tapptitude-swift into your Xcode project using CocoaPods, specify it in your `Podfile`

```bash
use_frameworks!
pod 'Tapptitude', :git => 'https://github.com/tapptitude/tapptitude-swift'
```

## Contains
* CollectionFeedController
* CollectionCellController
* TableFeedController
* TableCellController
* DataSource
* SectionedDataSource
* GroupedByDataSource
* FilteredDataSource
* SwipeToEditOnCollection

## Usage

### CollectionFeedController

Create Model class and UICollectionViewCell

``` swift
class MyCell: UICollectionViewCell {
    //code
}

class MyClass {
    //parameters
}
```

Create Cell Controller

``` swift
import Tapptitude

class MyCellController: CollectionCellController<MyClass, MyCell> {

    init() {
        //create cell with full width and height = 100
        super.init(cellSize: CGSize(width: -1, height: 100))
    }

    override func configureCell(_ cell: MyCell, for content: MyClass, at indexPath: IndexPath) {
        //configure your cell with given content
    }
}
```

Setup your ViewController screen with UICollectionView

``` swift
import Tapptitude

class MyScreenViewController: CollectionFeedController {

    override func viewDidLoad() {
        super.viewDidLoad()

        cellController = MyCellController()
        dataSource = DataSource([MyClass()])
    }
}
```

### TableFeedController

Create Model class and UITableViewCell

``` swift
class MyCell: UITableViewCell {
    //code
}

class MyClass {
    //parameters
}
```

Create Cell Controller

``` swift
import Tapptitude

class MyCellController: TableCellController<MyClass, MyCell> {

    init() {
        super.init(rowEstimatedHeight: 44)
    }

    override func configureCell(_ cell: MyCell, for content: MyClass, at indexPath: IndexPath) {
        //configure your cell with given content
    }
}
```

Setup your ViewController screen with UITableView

``` swift
import Tapptitude

class MyScreenViewController: TableFeedController {

    override func viewDidLoad() {
        super.viewDidLoad()

        cellController = MyCellController()
        dataSource = DataSource([MyClass()])
    }
}
```

## Contributing 👩‍💻👨‍💻
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

**tapptitude-swift** is released under the [MIT License](https://github.com/tapptitude/tapptitude-swift/blob/master/LICENSE).
