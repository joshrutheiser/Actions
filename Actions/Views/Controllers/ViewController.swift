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
//    lazy var viewModel = BacklogViewModel(model)
    var list = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ActionCell", bundle: nil), forCellReuseIdentifier: "ActionCell")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        
        addView(tableView, toParent: content)
        
        Task.detached(priority: .background) {
            do {
                try await self.model.startListening()
                try await self.model.write.createAction("A")
                try await self.model.write.createAction("B http://google.com", rank: 1)
                try await self.model.write.createAction("C", rank: 2)
            } catch {
                print(error)
            }
        }
    }
}

//MARK: - Table Data Source

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath) as! ActionCell
        if let action = try? model.read.getAction(list[indexPath.row]) {
            cell.setup(action)
            cell.delegate = self
        }
        return cell
    }
    
}

//MARK: - Action cell delegate

extension ViewController: ActionCellDelegate {
    func complete(_ actionId: String) {
        
    }
    
    func textEvent(_ actionId: String, _ event: TextEvent) {
        print("Action: \(actionId), Event: \(event)")
        switch event {
        case .Tapped:
            return
        case .Modified:
            updateHeight()
        case .Backspace:
            return
        case .Enter(_):
            return
        case .Save(let text):
            Task { [weak self] in
                try await self?.model.write.saveActionText(actionId, text)
            }
        }
    }
    
    
}


//MARK: - Cache delegate

extension ViewController: LocalCacheDelegate {
    
    func dataUpdated() {
        list = []
        guard let backlogIds = try? model.read.getBacklog() else { return }
        list = backlogIds
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

//MARK: - Private functions

extension ViewController {
    
    private func addView(_ child: UIView, toParent parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor)
        ])
    }
    
    
    private func updateHeight() {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
}
