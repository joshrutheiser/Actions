//
//  ViewController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import UIKit
import Firebase

class ViewController: UIViewController, LocalCacheDelegate {
    func dataUpdated() {
        let actions = model!.read.getActions()
        print(" > DATA UPDATED")
        print("   > USER")
        print(try! model!.read.getUser().toString())
        print("   > ACTIONS")
        actions.values.forEach({ print($0.toString()) })
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
                print("CREATE USER")
                try await model!.startListening()
                print("CREATE A")
                let idA = try await model!.write.createAction("A")
                try await Task.sleep(nanoseconds: 10000000000)
                print("CREATE B WITH PARENT A")
                let idB = try await model!.write.createAction("B", parentId: idA)
                try await Task.sleep(nanoseconds: 10000000000)
                print("CREATE C")
                let idC = try await model!.write.createAction("C")
                try await Task.sleep(nanoseconds: 10000000000)
                print("MOVE C TO PARENT B")
                try await model!.write.moveActionTo(idC!, parentId: idB)

//                print("DELETE A")
//                try await model!.write.deleteAction(idA!)
//                print("COMPLETE B")
//                try await model!.write.completeAction(idB!)
            } catch {
                print(error)
            }
        }
        
//        Task {
//            while true {
//                try await Task.sleep(nanoseconds: 10000000000)
//                let actions = model!.read.getActions()
//                print("READ CURRENT STATE")
//                print("USER")
//                print(try model!.read.getUser().toString())
//                print("ACTIONS")
//                actions.values.forEach({ print($0.toString()) })
//            }
//        }
    }


}

