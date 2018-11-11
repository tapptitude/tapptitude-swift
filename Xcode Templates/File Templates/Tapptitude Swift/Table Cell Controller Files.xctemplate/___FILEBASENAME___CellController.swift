//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  ___COPYRIGHT___
//

import UIKit
import Tapptitude

class ___VARIABLE_productName___CellController: TableCellController<___VARIABLE_contentType___, ___VARIABLE_productName___Cell> {
    
    init() {
        super.init(cellHeight: <#height#>)
    }
    
//    custom cell height
//    override func cellHeight(for content: ___VARIABLE_contentType___, in tableView: UITableView) -> CGFloat {
//        return <#code#>
//    }

    override func configureCell(_ cell: ___VARIABLE_productName___Cell, for content: ___VARIABLE_contentType___, at indexPath: IndexPath) {
    }
    
    override func didSelectContent(_ content: ___VARIABLE_contentType___, at indexPath: IndexPath, in tableView: UITableView) {
    }
}
