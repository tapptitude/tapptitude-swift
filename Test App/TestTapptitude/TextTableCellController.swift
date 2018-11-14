//
//  TextTableCellController.swift
//  TestTapptitude
//
//  Created by Alexandru Tudose on 14/11/2018.
//  Copyright © 2018 Tapptitude. All rights reserved.
//

import UIKit
import Tapptitude

class TextTableCellController: TableCellController<String, TextTableCell> {
    init() {
        super.init(cellHeight: 400)
    }
    
    override func configureCell(_ cell: TextTableCell, for content: String, at indexPath: IndexPath) {
        cell.label.text = content
        cell.subtitleLabel?.text = content
    }
    
    override func didSelectContent(_ content: String, at indexPath: IndexPath, in tableView: UITableView) {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TestViewController")
        self.parentViewController?.navigationController?.pushViewController(controller, animated: true)
    }
}
