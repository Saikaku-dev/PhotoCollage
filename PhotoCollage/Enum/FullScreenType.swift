//
//  FullScreentype.swift
//  PhotoCollage
//
//  Created by cmStudent on 2025/06/23.
//

import Foundation

enum FullScreenType: Identifiable {
    case camera
    case library
    case editing
    
    var id: Int {
        switch self {
        case .camera: return 1
        case .library: return 2
        case .editing: return 3
        }
    }
}
