//
//  ListSwiper.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/22/23.
//

import Foundation
import UIKit

class ListSwiper: NSObject {
    let dataSource: DataSource
    let listEditor: ListEditHandler
    
    init(_ dataSource: DataSource, _ listEditor: ListEditHandler) {
        self.dataSource = dataSource
        self.listEditor = listEditor
    }
}

extension ListSwiper: UITableViewDelegate {

    //MARK: - Leading swipe
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        //MARK: - Delete
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in

            DispatchQueue.main.async {
                let actionId = self.dataSource.ids[indexPath.row]
                self.listEditor.delete(actionId)
            }

            completionHandler(true)
        }

        delete.backgroundColor = UIColor(named: "DestructiveAction")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //MARK: - Trailing swipe
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        //MARK: - Skip
        
        let skip = UIContextualAction(style: .normal, title: "Skip") { (action, view, completionHandler) in
            

            completionHandler(true)
        }

        skip.backgroundColor = UIColor(named: "ConstructiveAction")
        
        //MARK: - Schedule
        
        let schedule = UIContextualAction(style: .normal, title: "Schedule") { (action, view, completionHandler) in
            

            completionHandler(true)
        }

        schedule.backgroundColor = UIColor(named: "ConstructiveAction2")
        
        return UISwipeActionsConfiguration(actions: [skip, schedule])
    }
}
