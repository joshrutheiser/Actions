//
//  DataSource.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/18/23.
//

import Foundation
import UIKit

protocol DataSource: UITableViewDataSource {
    var model: ModelController { get }
    var ids: [String] { get set }
    func register(_ tableView: UITableView)
    func reload()
}
