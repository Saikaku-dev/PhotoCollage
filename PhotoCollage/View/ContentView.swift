//
//  ContentView.swift
//  PhotoCollage
//
//  Created by cmStudent on 2025/06/23.
//

import SwiftUI

// メインコンテンツビュー
struct ContentView: View {
    @State var vm = ContentViewModel()
    @State private var fullScreenType: FullScreenType?
    
    var body: some View {
        VStack {
            // ヘッダー
            Header
            Divider()
            
            // ボディ
            uploadedImages
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(item: $fullScreenType) { type in
            switch type {
            case .camera:
                ImagePicker(seletedImage: $vm.capturedImage, sourceType: .camera, onImageSelected: {
                    DispatchQueue.main.async {
                        fullScreenType = .editing
                    }
                })
                .ignoresSafeArea()
            case .library:
                ImagePicker(seletedImage: $vm.capturedImage, sourceType: .photoLibrary, onImageSelected: {
                    DispatchQueue.main.async {
                        fullScreenType = .editing
                    }
                })
                .ignoresSafeArea()
            case .editing:
                EditingView(
                    image: $vm.capturedImage,
                    onSave: { editedImage in
                        vm.editedImage = editedImage
                    },
                    onComplete: {
                        fullScreenType = nil
                    }
                )
                .ignoresSafeArea()
            }
        }
    }
    
    // ヘッダー部分
    private var Header: some View {
        ScrollView(.horizontal) {
            HStack {
                // カメラボタン
                Button(action: {
                    fullScreenType = .camera
                }) {
                    btnStyle(img: "camera")
                }
                
                // ライブラリボタン
                Button(action: {
                    fullScreenType = .library
                }) {
                    btnStyle(img: "folder")
                }
            }
            .padding(.horizontal)
        }
    }
    
    // アップロード画像表示エリア
    private var uploadedImages: some View {
        VStack {
            if let editedImage = vm.editedImage {
                // 編集済み画像を表示
                Image(uiImage: editedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxHeight: 600)
    }
}

// ボタンスタイル拡張
extension View {
    func btnStyle(img: String) -> some View {
        Image(systemName: img)
            .resizable()
            .scaledToFit()
            .frame(width:30)
            .foregroundColor(Color(.systemGray2))
            .padding()
            .background(Color(.systemGray6))
            .clipShape(.circle)
    }
}

#Preview {
    ContentView()
}
