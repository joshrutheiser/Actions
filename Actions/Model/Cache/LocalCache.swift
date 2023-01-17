//
//  LocalCache.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/1/23.
//

import Foundation

//MARK: - Local Cache Delegate

protocol LocalCacheObserver: NSObject {
    func dataUpdated(source: UpdateSource)
}

enum UpdateSource {
    case Internal
    case External
}

//MARK: - Local Cache

struct LocalCache {
    var user: User?
    var actions: [String: Action]?
    var observers = [LocalCacheObserver]()
    
    //MARK: - Set user
    
    mutating func setUser(_ user: User) {
        self.user = user
    }

    //MARK: - Set action
    
    mutating func setAction(_ action: Action) {
        initActions()
        guard let id = action.id else { return }
        actions![id] = action
    }
    
    mutating func setActions(_ updates: [Difference<Action>]) {
        initActions()
        
        for update in updates {
            guard let id = update.object.id else { continue }
            switch update.change {
            case .Remove:
                // to prevent app crashes, don't remove from cache
                continue
            case .Set:
                actions![id] = update.object
            }
        }
    }
    
    mutating private func initActions() {
        if actions == nil {
            actions = [String: Action]()
        }
    }
    
    //MARK: - Remove action
    
    mutating func removeAction(_ action: Action) throws {
        guard actions != nil else {
            throw CacheError.UnableToRemoveAction(action.id)
        }
        guard let id = action.id else { return }
        actions![id] = nil
    }
    
    //MARK: - Notify
    
    func notify(source: UpdateSource) {
        observers.forEach({ $0.dataUpdated(source: source) })
    }
}
