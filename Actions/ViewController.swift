//
//  ViewController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/25/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var content: UIView!
    var model = ModelController()
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let ops = Operations()
        let id = ops.createAction("testing")
        print(id)
        ops.execute()
    }


}

