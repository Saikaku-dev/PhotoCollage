//
//  TextElement.swift
//  PhotoCollage
//
//  Created by cmStudent on 2025/06/24.
//
import Foundation

// テキスト要素を管理する構造体
struct TextElement: Identifiable {
    let id = UUID()
    var title: String
    var position: CGPoint
    var scale: CGFloat = 1.0
}
