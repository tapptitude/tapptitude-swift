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
//    override func cellSize(for content: ___VARIABLE_contentType___, in collectionView: UICollectionView) -> CGSize {
//        return <#code#>
//    }
    
    override func configureCell(_ cell: ___FILEBASENAME___Cell, for content: ___VARIABLE_contentType___, at indexPath: IndexPath) {
    }
    
    override func didSelectContent(_ content: ___VARIABLE_contentType___, at indexPath: IndexPath, in collectionView: UICollectionView) {
        
    }
}
