//
//  ListController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import UIKit

//MARK: - List Controller

class ListController: UIViewController {
    lazy var listEditor = ListEditHandler(model, tableView)
    lazy var dataSource = DataSource(model, listEditor)
    lazy var listSwiper = ListSwiper(dataSource, listEditor)
    let model: ModelController
    let tableView = UITableView()
    var addButton: AddButton?
    
    // add parent id, null is backlog
    
    init(_ model: ModelController) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        model.addObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("unsupported")
    }
    
    deinit {
        model.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.register(tableView)
        tableView.dataSource = dataSource
        tableView.dragDelegate = self
        tableView.delegate = listSwiper
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        view.addChildView(tableView)
        
        addButton = AddButton(view)
        addButton?.addTarget(
            self,
            action: #selector(addPressed),
            for: .touchUpInside
        )
        view.addSubview(addButton!)
    }
    
    func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.listEditor.stopEditing()
        }
    }
    
    
}

//MARK: - Drag and drop

extension ListController: UITableViewDragDelegate
{
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = dataSource.ids[indexPath.row]
        return [dragItem]
    }
}

//MARK: - Add pressed

extension ListController {
    @objc func addPressed() {
        DispatchQueue.main.async {
            self.listEditor.add()
        }
    }
}


//MARK: - Data updated

extension ListController: LocalCacheObserver {
    func dataUpdated(source: UpdateSource) {
        dataSource.reload()
        if source == .External {
            reload()
        }
    }
}

