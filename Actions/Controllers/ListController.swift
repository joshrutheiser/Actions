//
//  ListController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import UIKit
import Firebase

/*
 
 Responsibility = Build list view
 
 */

class ListController: UIViewController {
    let model: ModelController
    let tableView = UITableView()
    lazy var listEditor = ListEditHandler(model, tableView)
    lazy var dataSource: DataSource = BacklogDataSource(model, listEditor)
    
    // add parent id, null is backlog
    
    init(_ model: ModelController) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.register(tableView)
        tableView.dataSource = dataSource
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        view.addChildView(tableView)
    }
    
    func reload() {
        dataSource.reload()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
