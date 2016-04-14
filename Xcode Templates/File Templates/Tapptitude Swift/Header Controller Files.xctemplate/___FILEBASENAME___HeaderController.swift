//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import Tapptitude

class ___FILEBASENAME___HeaderController: CollectionHeaderController<___VARIABLE_contentType___, ___FILEBASENAME___HeaderCell> {
    init() {
        super.init(headerSize: CGSizeMake(-1, 30))
    }
    
    override func configureHeader(header: ___FILEBASENAME___HeaderCell, forContent content: ___VARIABLE_contentType___, indexPath: NSIndexPath) {
        header.titleLabel.text = content.dateAsString
    }
}
