//
//  Tip.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import Foundation

// MARK: - Tip

struct Tip: Identifiable, Decodable {
    let id: String
    let emoji: String
    let title: String
    let body: String
}
