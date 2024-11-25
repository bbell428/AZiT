//
//  EditPhotoView.swift
//  Azit
//
//  Created by 박준영 on 11/22/24.
//
import SwiftUI

struct EditPhotoView: View {
    @EnvironmentObject var cameraService: CameraService
    @EnvironmentObject var editPhotoService: EditPhotoStore

    @Binding var isDisplayTextEditor: Bool // 이미지 편집에 들어갈 텍스트 편집 뷰
    @Binding var isSelectText: Bool // 이미지에 텍스트를 넣을것인가?
    
    var body: some View {
        VStack(spacing: 0) {
//            Text("스토리에 올리기 전에 이미지를 편집할 수 있습니다.")
//                .font(.caption)
            if cameraService.capturedImage != nil {
                ZStack() {
                    ZStack(alignment: .topTrailing) {
                        Button {
                            isSelectText = true
                            isDisplayTextEditor.toggle()
                        } label: {
                            Image(systemName: "pencil.circle")
                                .font(.largeTitle)
                                .foregroundStyle(isSelectText && !editPhotoService.textInput.isEmpty ? .accent : .gray)
                                .background(Color.white.opacity(0.8))
                        }
                        .cornerRadius(15)
                        .padding()
                        .zIndex(4)
                        
                        Image(uiImage: cameraService.capturedImage!)
                            .resizable()
                            .aspectRatio(3/4, contentMode: .fit)
                            .scaleEffect(editPhotoService.imageScale)
                            .rotationEffect(editPhotoService.imageRotation)
                            .offset(CGSize(width: editPhotoService.currentImageOffset.width + editPhotoService.imageDragOffset.width,
                                           height: editPhotoService.currentImageOffset.height + editPhotoService.imageDragOffset.height))
                            .gesture(
                                SimultaneousGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            guard !editPhotoService.isTextGestureActive else { return } // 텍스트 제스처 활성 시 비활성화
                                            editPhotoService.isImageGestureActive = true
                                            editPhotoService.imageDragOffset = value.translation
                                        }
                                        .onEnded { _ in
                                            guard !editPhotoService.isTextGestureActive else { return }
                                            editPhotoService.currentImageOffset = CGSize(
                                                width: editPhotoService.currentImageOffset.width + editPhotoService.imageDragOffset.width,
                                                height: editPhotoService.currentImageOffset.height + editPhotoService.imageDragOffset.height
                                            )
                                            editPhotoService.imageDragOffset = .zero
                                            editPhotoService.isImageGestureActive = false
                                        },
                                    SimultaneousGesture(
                                        MagnificationGesture()
                                            .onChanged { value in
                                                guard !editPhotoService.isTextGestureActive else { return }
                                                editPhotoService.isImageGestureActive = true
                                                editPhotoService.imageScale = editPhotoService.currentImageScale * value
                                            }
                                            .onEnded { value in
                                                guard !editPhotoService.isTextGestureActive else { return }
                                                editPhotoService.currentImageScale = editPhotoService.imageScale
                                                editPhotoService.isImageGestureActive = false
                                            },
                                        RotationGesture()
                                            .onChanged { angle in
                                                guard !editPhotoService.isTextGestureActive else { return }
                                                editPhotoService.isImageGestureActive = true
                                                editPhotoService.imageRotation = angle
                                            }
                                            .onEnded { _ in
                                                editPhotoService.isImageGestureActive = false
                                            }
                                    )
                                )
                            )
                            .frame(width: editPhotoService.frameSize.width, height: editPhotoService.frameSize.height)
                            .clipped()
                            .zIndex(3)
                    }
                    
                    // 사용자가 텍스트를 넣겠다고 하고, 공백이 없을때만 보여주기
                    if isSelectText && !editPhotoService.textInput.isEmpty && !isDisplayTextEditor {
                        Text(editPhotoService.textInput)
                            .font(.title3)
                            .foregroundColor(editPhotoService.isTextColor[editPhotoService.selectedTextColor])
                            .shadow(radius: 5)
                            .frame(maxWidth: 250, alignment: .center)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 15)
                            .background(editPhotoService.isBackgroundText ? editPhotoService.isTextColor[editPhotoService.selectedTextColor] == .white ? Color.black.opacity(0.8) : Color.white.opacity(0.8) : Color.clear)
                            .cornerRadius(15)
                            .scaleEffect(editPhotoService.scale)
                            .rotationEffect(editPhotoService.rotation)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: true, vertical: true)
                            .offset(CGSize(width: editPhotoService.textPosition.width + editPhotoService.dragOffset.width,
                                           height: editPhotoService.textPosition.height + editPhotoService.dragOffset.height))
                            .gesture(
                                SimultaneousGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            guard !editPhotoService.isImageGestureActive else { return } // 이미지 제스처 활성 시 비활성화
                                            editPhotoService.isTextGestureActive = true
                                            editPhotoService.dragOffset = value.translation
                                        }
                                        .onEnded { _ in
                                            guard !editPhotoService.isImageGestureActive else { return }
                                            let newPosition = CGSize(
                                                width: editPhotoService.textPosition.width + editPhotoService.dragOffset.width,
                                                height: editPhotoService.textPosition.height + editPhotoService.dragOffset.height
                                            )

                                            let halfWidth = editPhotoService.frameSize.width / 2
                                            let halfHeight = editPhotoService.frameSize.height / 2
                                            editPhotoService.textPosition = CGSize(
                                                width: min(max(newPosition.width, -halfWidth), halfWidth),
                                                height: min(max(newPosition.height, -halfHeight), halfHeight)
                                            )
                                            editPhotoService.dragOffset = .zero
                                            editPhotoService.isTextGestureActive = false
                                        },
                                    SimultaneousGesture(
                                        MagnificationGesture()
                                            .onChanged { value in
                                                guard !editPhotoService.isImageGestureActive else { return }
                                                editPhotoService.isTextGestureActive = true
                                                editPhotoService.scale = value
                                            }
                                            .onEnded { _ in
                                                editPhotoService.isTextGestureActive = false
                                            },
                                        RotationGesture()
                                            .onChanged { angle in
                                                guard !editPhotoService.isImageGestureActive else { return }
                                                editPhotoService.isTextGestureActive = true
                                                editPhotoService.rotation = angle
                                            }
                                            .onEnded { _ in
                                                editPhotoService.isTextGestureActive = false
                                            }
                                    )
                                )
                            )
                            .zIndex(2)
                    }
                }
                .frame(width: editPhotoService.frameSize.width, height: editPhotoService.frameSize.height)
                .background(Color.black)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.accent, lineWidth: 2)
                )
                .padding(.vertical, 10)
            }
        }
    }
}
