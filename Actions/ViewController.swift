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
    var dbListener = DatabaseListener()
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let openActions = Firestore.firestore().collection(Action.collection())
        dbListener.listenCollection(as: Action.self, openActions) { results in
            print(results)
        }
        
        let id = dbWriter.create(as: Action.self, Action(userId: "123", text: "test"))
        dbWriter.execute()
        print(id ?? "no id")
    }


}

