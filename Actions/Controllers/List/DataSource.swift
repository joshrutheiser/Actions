//
//  Data Source.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/7/23.
//

import Foundation
import UIKit

//MARK: - Data Source

class DataSource: NSObject, UITableViewDataSource {
    private let delegate: ActionCellDelegate
    var model: ModelController
    var ids = [String]()
    var ranks = [String: Int]()
    
    init(_ model: ModelController, _ delegate: ActionCellDelegate) {
        self.model = model
        self.delegate = delegate
        super.init()
    }
    
    func storedRank(_ actionId: String) -> Int? {
        return ranks[actionId]
    }
    
    func reload() {
        ids = model.read.getBacklog() ?? []
        for i in 0..<ids.count {
            let id = ids[i]
            ranks[id] = i
        }
    }
    
    func register(_ tableView: UITableView) {
        tableView.register(UINib(nibName: "ActionCell", bundle: nil), forCellReuseIdentifier: "ActionCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ids.count
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        let actionId = ids[sourceIndexPath.row]
        try? model.write.moveAction(actionId, rank: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell

        let actionId = ids[indexPath.row]
        if let action = try? model.read.getAction(actionId) {
            cell.id = actionId
            cell.setText(action.text)
            cell.delegate = delegate
        }
        return cell
    }
    
}
