//
//  ViewController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import UIKit
import Firebase

class ViewController: UIViewController, LocalCacheDelegate {
    func userUpdated(_ user: User) {
         print(user)
    }
    
    func actionsUpdated(_ actions: [String: Action]) {
         print(actions)
    }
    
    @IBOutlet weak var content: UIView!
    var model: ModelController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model = ModelController(UUID().uuidString, self)
//        let userId = "testing"
//        model = ModelController(userId, self)
//
//        Task {
//            try await model.load()
//        }
        
        Task {
            do {
                try await model!.load()
                try await model!.write.createAction("test")
                
            } catch {
                print(error)
            }
        }
    }


}

