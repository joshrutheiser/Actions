//
//  ViewController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    @IBOutlet weak var content: UIView!
    var dbWriter = DatabaseWriter()
    var dbListener = DatabaseReader()
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let openActions = Firestore.firestore().collection(Action.collection())
//
//        dbListener.listenCollection(as: Action.self, openActions) { results in
//            print(results)
//        }
//        do {
//            var action = Action(userId: "123", text: "do this thing first")
//            let id = try dbWriter.create(as: Action.self, action)
//            dbWriter.execute()
//            print(id)
//
//            action.id = id
//            action.text = "do this thing second"
//
//            try dbWriter.update(as: Action.self, action)
//            dbWriter.execute()
//
//        } catch {
//            print(error)
//        }
    }


}

