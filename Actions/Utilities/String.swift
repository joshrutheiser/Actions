//
//  String.swift
//  Actions
//
//  Created by Josh Rutheiser on 1/16/23.
//

import Foundation

extension String {
    
    //MARK: - Trim
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    //MARK: - Split
    
    func split(_ location: Int) -> (String, String) {
        let index = self.index(self.startIndex, offsetBy: location)
        let first = String(self.prefix(upTo: index))
        let second = String(self.suffix(from: index))
        return (first, second)
    }
    
}
