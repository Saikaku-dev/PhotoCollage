//
//  ContentViewModel.swift
//  PhotoCollage
//
//  Created by cmStudent on 2025/06/23.
//

import Foundation
import Observation
import UIKit

@Observable
final class ContentViewModel {
    var showCameraScreen: Bool = false
    var capturedImage: UIImage?
    var editedImage: UIImage?
}
