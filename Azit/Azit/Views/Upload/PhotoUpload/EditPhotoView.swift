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

    var body: some View {
        VStack {
            if cameraService.capturedImage != nil {
                ZStack {
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

                    TextField("텍스트를 입력하세요", text: $editPhotoService.textInput)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(10)
                        //.background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .scaleEffect(editPhotoService.scale)
                        .rotationEffect(editPhotoService.rotation)
                        .multilineTextAlignment(.center)
                        .fixedSize()
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
                }
                .frame(width: editPhotoService.frameSize.width, height: editPhotoService.frameSize.height)
                .background(Color.black)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 2)
                )
                .padding()
            }

//            Button(action: {
//                editPhotoService.saveImage()
//            }) {
//                Text("이미지 저장")
//                    .font(.headline)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
        }
    }
}
