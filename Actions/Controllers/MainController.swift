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
                let d = try await self.model.write.createAction("D", rank: 3)
                let e = try await self.model.write.createAction("E", rank: 4)
                try await self.model.write.createAction("F", rank: 5)
                try await self.model.write.createAction("G", rank: 6)
                try await self.model.write.createAction("H", rank: 7)
                try await self.model.write.createAction("I", rank: 8)
                try await self.model.write.skip(d!)
                try await self.model.write.skip(e!)
//                await self.list.dataSource.reload()
                await self.list.reload()
            } catch {
                print(error)
            }
        }
    }
}
