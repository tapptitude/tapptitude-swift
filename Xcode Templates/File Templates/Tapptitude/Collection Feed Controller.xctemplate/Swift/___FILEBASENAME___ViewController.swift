//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

class ___FILEBASENAME___ViewController : TTCollectionFeedViewController {

    init() {
        super.init(nibName: "___FILEBASENAME___ViewController", bundle: nil)
        
        self.cellController = ___VARIABLE_ColectionCellController___CellController()
        self.dataSource = TTDataSource(staticContent:["Test"])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
