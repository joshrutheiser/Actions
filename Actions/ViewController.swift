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
    var databaseWriter: DatabaseWriter!
    var databaseReader: DatabaseReader!
    var model: ModelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseWriter = DatabaseWriter()
        databaseReader = DatabaseReader()
        let userId = UUID().uuidString
        let session = "session_\(UUID().uuidString)"
        
        model = ModelController(session, databaseReader, databaseWriter)
        
        Task {
            try! await model.setupUser(userId)
            
            while true {
                let user = await model.data.user!
//                try! await Task.sleep(nanoseconds: 1000000)
                print("\(Date().timeIntervalSince1970 * 1000): \(user.lastSession)")
            }
        }
        
        
        
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

