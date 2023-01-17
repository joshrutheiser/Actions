//
//  MainController.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/15/23.
//

import Foundation
import UIKit

class MainController: UIViewController {
    
    @IBOutlet weak var content: UIView!
    lazy var model = ModelController(UUID().uuidString)
    lazy var list = ListController(model)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildController(list, toView: content)
        
        Task.detached(priority: .background) {
            do {
                try await self.model.startListening()
                try await self.model.write.createAction("A")
                try await self.model.write.createAction("B http://google.com", rank: 1)
                try await self.model.write.createAction("C", rank: 2)
//                await self.list.dataSource.reload()
                await self.list.reload()
            } catch {
                print(error)
            }
        }
    }
}
