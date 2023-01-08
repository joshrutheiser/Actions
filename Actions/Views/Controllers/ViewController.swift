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
    let tableView = UITableView()
    lazy var model = ModelController(UUID().uuidString, self)
    lazy var viewModel = BacklogViewModel(model)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        addView(tableView, toParent: content)
        
        Task.detached(priority: .background) {
            do {
                try await self.model.startListening()
                try await self.model.write.createAction("A")
                try await self.model.write.createAction("B")
                try await self.model.write.createAction("C")
            } catch {
                print(error)
            }
        }
    }
}

//MARK: - Table Data Source

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = viewModel[indexPath.row].text
        return cell
    }
    
}

//MARK: - Cache delegate

extension ViewController: LocalCacheDelegate {
    
    func dataUpdated() {
        try? self.viewModel.reload()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

//MARK: - Private functions

extension ViewController {
    
    func addView(_ child: UIView, toParent parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
    }
    
}
