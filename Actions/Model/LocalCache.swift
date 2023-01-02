//
//  LocalCache.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/1/23.
//

import Foundation

//MARK: - Memory Cache Delegate

protocol LocalCacheDelegate {
    func userUpdated(_ user: User)
    func actionsUpdated(_ actions: [String: Action])
}

//MARK: - Memory Cache

actor LocalCache {
    var user: User?
    var actions: [String: Action]?
    var delegate: LocalCacheDelegate
    
    init(delegate: LocalCacheDelegate) {
        self.delegate = delegate
    }
    
    func updateUser(_ user: User) {
        self.user = user
        delegate.userUpdated(user)
    }

    func updateActions(_ updates: [Difference<Action>]) {
        if actions == nil {
            actions = [String: Action]()
        }
        
        for update in updates {
            guard let id = update.object.id else { continue }
            switch update.change {
            case .Remove:
                actions!.removeValue(forKey: id)
            case .Set:
                actions![id] = update.object
            }
        }
        
        delegate.actionsUpdated(actions!)
    }
}
