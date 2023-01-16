//
//  ViewUtilities.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/15/23.
//

import Foundation
import UIKit

//MARK: - Table View

extension UITableView {
    
    //MARK: - Update height
    
    func updateHeight() {
        UIView.setAnimationsEnabled(false)
        self.beginUpdates()
        self.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    //MARK: - Add row
    
    func addRow(_ index: Int) {
        UIView.setAnimationsEnabled(false)
        self.beginUpdates()
        self.insertRows(at: [IndexPath(row: index, section: 0)], with: .none)
        self.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    //MARK: - Move row
    
    func moveRow(from: Int, to: Int) {
        UIView.setAnimationsEnabled(false)
        self.moveRow(at: IndexPath(row: from, section: 0), to: IndexPath(row: to, section: 0))
        UIView.setAnimationsEnabled(true)
        self.beginUpdates()
        self.endUpdates()
    }
    
    //MARK: - Remove row
    
    func removeRow(_ index: Int) {
        UIView.setAnimationsEnabled(false)
        self.beginUpdates()
        self.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
        self.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
}

//MARK: - View

extension UIView {
    
    //MARK: - Add child view
    
    func addChildView(_ child: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: self.topAnchor),
            child.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            child.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    //MARK: - From Nib
    
    static func fromNib<T: UIView>() -> T {
        let name = String(describing: Self.self)
        guard let nib = Bundle(for: Self.self).loadNibNamed(name, owner: nil, options: nil) else {
            fatalError("Missing nib-file named: \(name)")
        }
        
        return nib.first as! T
    }
    
}

//MARK: - View Controller

extension UIViewController {
    
    //MARK: - Add child
    
    func addChildController(_ child: UIViewController, toView: UIView? = nil) {
        let view: UIView = toView ?? self.view
        addChild(child)
        view.addChildView(child.view)
        child.didMove(toParent: self)
    }

    //MARK: - Remove child
    
    func removeChild() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
}
