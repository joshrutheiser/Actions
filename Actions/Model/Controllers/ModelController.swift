//
//  ModelController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/31/22.
//

import Foundation

//MARK: - Model Controller

class ModelController {
    private let dataSync: DataSync
    let read: ReadController
    let write: WriteController

    init(_ config: DataSyncConfig) {
        dataSync = DataSync(config)
        read = ReadController(dataSync)
        write = WriteController(dataSync, read)
    }
    
    convenience init(_ userId: String)
    {
        let config = DataSyncConfig(
            session: UUID().uuidString,
            userId: userId
        )
        self.init(config)
    }
    
    func startListening() async throws {
        try await read.startListening()
    }
    
    var user: User? {
        get {
            try? read.getUser()
        }
    }
    
    var actions: [String: Action]? {
        get {
            read.getActions()
        }
    }
    
    func addObserver(_ observer: LocalCacheObserver) {
        dataSync.addObserver(observer)
    }
    
    func removeObserver(_ observer: LocalCacheObserver) {
        dataSync.removeObserver(observer)
    }
}
