//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import UIKit
import Tapptitude

class ___FILEBASENAME___ViewController : CollectionFeedController {

    init() {
        super.init(nibName: "___FILEBASENAME___ViewController", bundle: nil)
        
        self.cellController = ___VARIABLE_ColectionCellController___CellController()
        self.dataSource = DataSource(["Test content"])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
