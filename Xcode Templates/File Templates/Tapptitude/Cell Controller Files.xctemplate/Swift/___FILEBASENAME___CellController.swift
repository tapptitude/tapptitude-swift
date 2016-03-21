//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

class ___FILEBASENAME___CellController: TTBlockCollectionCellController {
    
    override init() {
        super.init(cellNibName: "___FILEBASENAME___Cell", bundle:nil, contentSize: CGSizeMake(-1.0, <#height#>.0))
        
        self.minimumInteritemSpacing = 0.0
        self.minimumLineSpacing = 0.0
        self.sectionInset = UIEdgeInsetsZero
    }
    
    override func acceptsContent(content: AnyObject!) -> Bool {
        return content is <#Class#>
    }
    
    override func configureCell(cell: UICollectionViewCell!, forContent content: AnyObject!, indexPath: NSIndexPath!) {
    }
}
