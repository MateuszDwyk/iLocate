//
//  Beacon.swift
//  iLocateApp
//
//  Created by Mateusz Dworaczyk on 14/12/2023.
//

import Foundation

struct Beacon {
    let id: String
    let roomId: String
    let uuid: String
    let position: [String: Double] // Assuming position is a map with keys "x", "y", "z"
    let name: String
    let description: String
}
