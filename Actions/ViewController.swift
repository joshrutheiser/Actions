//
//  ViewController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import UIKit
import Firebase

class ViewController: UIViewController, LocalCacheDelegate {
    func userUpdated() {
         
    }
    
    func actionsUpdated() {
         
    }
    
    @IBOutlet weak var content: UIView!
    var model: ModelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let userId = "testing"
//        model = ModelController(userId, self)
//
//        Task {
//            try await model.load()
//        }
    }


}

