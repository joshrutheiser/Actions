//
//  BacklogDataSource.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/7/23.
//

import Foundation
import UIKit

/*
 
 Responsibility = read data from model and build cells
 
 */

protocol DataSource: UITableViewDataSource {
    var model: ModelController { get }
    var ids: [String] { get set }
    func register(_ tableView: UITableView)
    func reload()
}

class BacklogDataSource: NSObject, DataSource {
    var model: ModelController
    private let delegate: ActionCellDelegate
    var ids = [String]()
    
    init(_ model: ModelController, _ delegate: ActionCellDelegate) {
        self.model = model
        self.delegate = delegate
    }
    
    func register(_ tableView: UITableView) {
        tableView.register(UINib(nibName: "ActionCell", bundle: nil), forCellReuseIdentifier: "ActionCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ids.count
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
    
    func reload() {
        do {
            ids = try model.read.getBacklog()
        } catch {
            print(error.localizedDescription)
        }
    }
}

