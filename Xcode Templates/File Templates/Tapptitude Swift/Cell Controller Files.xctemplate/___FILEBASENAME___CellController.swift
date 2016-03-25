//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import UIKit
import Tapptitude

class ___FILEBASENAME___CellController: CollectionCellController<___VARIABLE_contentType___, ___FILEBASENAME___Cell> {
    
    init() {
        super.init(cellSize: CGSize(width: -1.0, height: <#height#>.0))
    }
    
//    custom cell size
//    override func cellSizeForContent(content: ___VARIABLE_contentType___, collectionView: UICollectionView) -> CGSize {
//        return <#code#>
//    }
    
    override func configureCell(cell: ___FILEBASENAME___Cell, forContent content: ___VARIABLE_contentType___, indexPath: NSIndexPath!) {
    }
    
    override func didSelectContent(content: ___VARIABLE_contentType___, indexPath: NSIndexPath, collectionView: UICollectionView) {
        
    }
}
