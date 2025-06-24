//
//  SavePreviewView.swift
//  PhotoCollage
//
//  Created by cmStudent on 2025/06/23.
//

import SwiftUI

class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func saveImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(
            image,
            self,
            #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }
    
    @objc func saveCompleted(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}


struct SavePreviewView: View {
    let image: UIImage
    @State private var isSaving = false
    @State private var saveCompleted = false
    @State private var saveError: Error? = nil
    @Environment(\.dismiss) private var dismiss
    
    var onComplete: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                if isSaving {
                    ProgressView("保存中...")
                } else if saveCompleted {
                    Text("保存成功!")
                        .foregroundColor(.green)
                        .padding()
                } else if let error = saveError {
                    Text("保存失败: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: saveToPhotoLibrary) {
                    Text("ライブラリに保存")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(isSaving || saveCompleted)
            }
            .navigationTitle("プレビュー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveToPhotoLibrary() {
        isSaving = true
        saveError = nil
        
        let saver = ImageSaver()
        saver.successHandler = {
            isSaving = false
            saveCompleted = true
            
            dismiss()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onComplete?()
            }
        }
        saver.errorHandler = { error in
            isSaving = false
            saveError = error
        }
        
        saver.saveImage(image)
    }
}
#Preview {
    SavePreviewView(image: UIImage(systemName: "photo")!)
}
