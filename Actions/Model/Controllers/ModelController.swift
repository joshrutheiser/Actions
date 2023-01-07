//
//  ModelController.swift
//  Actions
//
//  Created by Josh Rutheiser on 12/31/22.
//

import Foundation

//MARK: - Model Controller

class ModelController {
    var read: ReadController
    var write: WriteController

    init(_ config: DataSyncConfig) {
        let dataSync = DataSync(config)
        read = ReadController(dataSync)
        write = WriteController(dataSync, read)
    }
    
    convenience init(
        _ userId: String,
        _ delegate: LocalCacheDelegate)
    {
        let config = DataSyncConfig(
            databaseWriter: DatabaseWriter(),
            databaseReader: DatabaseReader(),
            cache: LocalCache(delegate),
            session: UUID().uuidString,
            userId: userId
        )
        self.init(config)
    }
    
    func startListening() async throws {
        try await read.startListening()
    }
    
}
