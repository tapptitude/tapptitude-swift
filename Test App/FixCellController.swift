//
//  FixCellController.swift
//  TestTapptitude
//
//  Created by Ion Toderasco on 13/12/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit
import Tapptitude

class FixCellController: TableCellController<Int, FixCell> {
    
    init() {
        super.init(rowEstimatedHeight: 200)
    }

    override func cellHeight(for content: Int, in tableView: UITableView) -> CGFloat {
        return 200
    }

    override func configureCell(_ cell: FixCell, for content: Int, at indexPath: IndexPath) {
        cell.titleLabel.text = String(content)
    }
}
