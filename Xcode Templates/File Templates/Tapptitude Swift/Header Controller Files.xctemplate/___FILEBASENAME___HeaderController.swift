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
        super.init(headerSize: CGSize(width: -1.0, height: <#height#>.0))
    }
    
    override func configureHeader(_ header: ___FILEBASENAME___HeaderCell, for content: ___VARIABLE_contentType___, indexPath: IndexPath) {
        header.titleLabel.text = <#code#>
    }
}
