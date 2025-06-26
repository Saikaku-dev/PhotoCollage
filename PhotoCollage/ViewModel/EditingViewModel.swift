//
//  EditingViewModel.swift
//  PhotoCollage
//
//  Created by cmStudent on 2025/06/23.
//
import Foundation
import Combine
import UIKit
import SwiftUI

// 編集画面のビューモデル
class EditingViewModel: ObservableObject {
    @Published var addedTexts: [TextElement] = []
    
    // テキストを追加するメソッド
    func addText(title: String, position: CGPoint) {
        let newText = TextElement(title: title, position: position)
        addedTexts.append(newText)
    }
    func updateTextElement(id: UUID, scale: CGFloat) {
        if let index = addedTexts.firstIndex(where: { $0.id == id }) {
            addedTexts[index].scale = scale
        }
    }
    // ビューを画像に変換するメソッド
    func snapshot(contentView: some View, size: CGSize) -> UIImage {
        let controller = UIHostingController(rootView: contentView)
        let view = controller.view!
        
        view.bounds = CGRect(origin: .zero, size: size)
        view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
