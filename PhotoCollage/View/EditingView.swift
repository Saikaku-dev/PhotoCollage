//
//  EditingView.swift
//  PhotoCollage
//
//  Created by cmStudent on 2025/06/23.
//
import SwiftUI
import UIKit

import Foundation
import Combine

// テキスト要素を管理する構造体
struct TextElement: Identifiable {
    let id = UUID()
    var title: String
    var position: CGPoint
    var scale: CGFloat = 1.0
}

// 編集画面のビューモデル
class EditingViewModel: ObservableObject {
    @Published var addedTexts: [TextElement] = []
    
    // テキストを追加するメソッド
    func addText(title: String, position: CGPoint) {
        let newText = TextElement(title: title, position: position)
        addedTexts.append(newText)
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

// 編集画面ビュー
struct EditingView: View {
    @StateObject var vm = EditingViewModel()
    @Binding var image: UIImage?
    @FocusState var focused: Bool
    @State private var text: String = ""
    @State private var textPosition: CGPoint? = nil
    @State private var showTextEditor: Bool = false
    @State private var finalImage: UIImage? = nil
    @State private var showSaveSheet = false
    
    @State var scale: CGFloat = 1.0
    @State var lastScale: CGFloat = 1.0
    
    // 保存完了時のコールバック
    var onSave: (UIImage) -> Void
    var onComplete: (() -> Void)?
    
    var body: some View {
        ZStack {
            // メイン背景
            Color.black.ignoresSafeArea()
            
            // 画像表示レイヤー
            if let image = image {
                GeometryReader { geometry in
                    let geoSize = geometry.size
                    let imgSize = image.size
                    let scale = min(geoSize.width / imgSize.width, geoSize.height / imgSize.height)
                    let displayWidth = imgSize.width * scale
                    let displayHeight = imgSize.height * scale
                    let offsetX = (geoSize.width - displayWidth) / 2
                    let offsetY = (geoSize.height - displayHeight) / 2
                    
                    // コンテンツ表示構造
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geoSize.width, height: geoSize.height)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        let loc = value.location
                                        // タップ位置が画像領域内か確認
                                        if loc.x >= offsetX, loc.x <= offsetX + displayWidth,
                                           loc.y >= offsetY, loc.y <= offsetY + displayHeight {
                                            textPosition = loc
                                            showTextEditor = true
                                            DispatchQueue.main.async {
                                                focused = true
                                            }
                                        }
                                    }
                            )
                        
                        // 追加されたテキストを表示
                        ForEach(vm.addedTexts) { text in
                            Text(text.title)
                                .foregroundColor(.black)
                                .position(text.position)
                        }
                    }
                    
                }
            } else {
                ProgressView()
            }
            
            // テキストエディタ表示中に背景を暗く
            if showTextEditor {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        focused = false
                    }
            }
            
            // テキスト入力フィールド
            if let pos = textPosition {
                TextField("", text: $text)
                    .frame(width: 50)
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .position(pos)
                    .focused($focused)
                    .onChange(of: focused) {
                        if !focused {
                            resetText()
                        }
                    }
            }
            
            // スクリーンショット用の非表示ビュー
            screenshotView
                .frame(width: 0, height: 0)
                .opacity(0)
        }
        // 保存プレビューシート
        .sheet(isPresented: $showSaveSheet) {
            if let finalImage = finalImage {
                SavePreviewView(image: finalImage, onComplete: {
                    self.onComplete?()
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: focused) {
            showTextEditor = focused
        }
        .overlay(alignment: .topTrailing) {
            // テキスト入力中の完了ボタン
            if showTextEditor, let pos = textPosition {
                Button("完了") {
                    if !text.isEmpty {
                        vm.addText(title: text, position: pos)
                    }
                    resetText()
                }
                .padding(8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(24)
            }
            // 保存ボタン（テキスト追加後表示）
            else if (vm.addedTexts.count > 0) {
                Button("保存") {
                    saveCollage()
                }
                .padding(8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(24)
            }
        }
        
    }
    
    // テキスト入力をリセット
    func resetText() {
        showTextEditor = false
        textPosition = nil
        text = ""
    }
    
    // スクリーンショット用ビュー
    private var screenshotView: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                
                ForEach(vm.addedTexts) { text in
                    Text(text.title)
                        .foregroundColor(.black)
                        .position(text.position)
                }
            }
        }
        .background(Color.clear)
    }
    
    // コラージュを保存
    private func saveCollage() {
        // レンダリング用コンテンツを作成
        let contentView = ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                
                ForEach(vm.addedTexts) { text in
                    Text(text.title)
                        .foregroundColor(.black)
                        .position(text.position)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        // ビューを画像に変換
        let collageImage = contentView.asImage()
        
        // コールバックで編集済み画像を渡す
        onSave(collageImage)
        
        // プレビュー表示用に画像を保存
        finalImage = collageImage
        showSaveSheet = true
    }
}

// ビューをUIImageに変換する拡張
extension View {
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = UIScreen.main.bounds.size
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
