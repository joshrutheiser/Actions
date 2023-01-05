//
//  LocalCache.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/1/23.
//

import Foundation

//MARK: - Local Cache Delegate

protocol LocalCacheDelegate {
    func userUpdated(_ user: User)
    func actionsUpdated(_ actions: [String: Action])
}

//MARK: - Local Cache

actor LocalCache {
    var user: User?
    var actions: [String: Action]?
    var delegate: LocalCacheDelegate
        
    init(_ delegate: LocalCacheDelegate) {
        self.delegate = delegate
    }
    
    //MARK: - Set user

    func setUser(_ user: User) {
        self.user = user
    }
    
    func setUserNotify(_ user: User) {
        self.user = user
        delegate.userUpdated(user)
    }

    //MARK: - Set action
    
    func setAction(_ action: Action) {
        initActions()
        guard let id = action.id else { return }
        actions![id] = action
    }
    
    func setActionsNotify(_ updates: [Difference<Action>]) {
        initActions()
        
        for update in updates {
            guard let id = update.object.id else { continue }
            switch update.change {
            case .Remove:
                actions![id] = nil
            case .Set:
                actions![id] = update.object
            }
        }
        
        delegate.actionsUpdated(actions!)
    }
    
    private func initActions() {
        if actions == nil {
            actions = [String: Action]()
        }
    }
    
    //MARK: - Remove action
    
    func removeAction(_ action: Action) throws {
        guard actions != nil else {
            throw CacheError.NoRemoveActionsNil(action.id)
        }
        guard let id = action.id else { return }
        actions![id] = nil
    }
    
    func removeActionNotify(_ action: Action) throws {
        try removeAction(action)
        delegate.actionsUpdated(actions!)
    }

}
