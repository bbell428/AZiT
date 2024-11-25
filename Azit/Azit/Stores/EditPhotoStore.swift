//
//  EditPhotoStore.swift
//  Azit
//
//  Created by 박준영 on 11/22/24.
//
import SwiftUI

class EditPhotoStore: ObservableObject {
    @ObservedObject var photoImageStore: PhotoImageStore

    @Published var savedImage: UIImage?
    @Published var textPosition: CGSize
    @Published var dragOffset: CGSize
    @Published var scale: CGFloat
    @Published var rotation: Angle
    @Published var imageRotation: Angle
    @Published var textInput: String

    @Published var imageScale: CGFloat
    @Published var imageDragOffset: CGSize
    @Published var currentImageOffset: CGSize
    @Published var currentImageScale: CGFloat

    @Published var isImageGestureActive: Bool
    @Published var isTextGestureActive: Bool

    @Published var isBackgroundText: Bool
    @Published var isTextColor: [Color]
    @Published var selectedTextColor: Int
    
    let frameSize: CGSize

    // 초기화 메서드
    init(
        photoImageStore: PhotoImageStore = PhotoImageStore(),
        textPosition: CGSize = .zero,
        dragOffset: CGSize = .zero,
        scale: CGFloat = 1.0,
        rotation: Angle = .zero,
        imageRotation: Angle = .zero,
        textInput: String = "",
        imageScale: CGFloat = 1.0,
        imageDragOffset: CGSize = .zero,
        currentImageOffset: CGSize = .zero,
        currentImageScale: CGFloat = 1.0,
        isImageGestureActive: Bool = false,
        isTextGestureActive: Bool = false,
        frameSize: CGSize = CGSize(width: 360, height: 480),
        isBackgroundText: Bool = false,
        isTextColor: [Color] = [.white, .black],
        selectedTextColor: Int = 0
    ) {
        self.photoImageStore = photoImageStore
        self.textPosition = textPosition
        self.dragOffset = dragOffset
        self.scale = scale
        self.rotation = rotation
        self.imageRotation = imageRotation
        self.textInput = textInput
        self.imageScale = imageScale
        self.imageDragOffset = imageDragOffset
        self.currentImageOffset = currentImageOffset
        self.currentImageScale = currentImageScale
        self.isImageGestureActive = isImageGestureActive
        self.isTextGestureActive = isTextGestureActive
        self.frameSize = frameSize
        self.isBackgroundText = isBackgroundText
        self.isTextColor = isTextColor
        self.selectedTextColor = selectedTextColor
        print("EditPhotoStore initialized")
    }

    // 상태 초기화 메서드
    func resetState() {
        savedImage = nil
        textPosition = .zero
        dragOffset = .zero
        scale = 1.0
        rotation = .zero
        imageRotation = .zero
        textInput = ""
        imageScale = 1.0
        imageDragOffset = .zero
        currentImageOffset = .zero
        currentImageScale = 1.0
        isImageGestureActive = false
        isTextGestureActive = false
        isBackgroundText = false
        selectedTextColor = 0
        print("State reset to initial values")
    }

    // 이미지 저장 및 업로드 후 초기화
    func saveImage(image: UIImage, id: String) async {
        let renderer = ImageRenderers(content: ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(3 / 4, contentMode: .fit)
                .scaleEffect(imageScale)
                .offset(currentImageOffset)
                .rotationEffect(imageRotation)

            Text(textInput)
                .font(.title3)
                .frame(maxWidth: 250, alignment: .center)
                .padding(.horizontal, 10)
                .padding(.vertical, 15)
                .foregroundColor(isTextColor[selectedTextColor])
                .background(isBackgroundText ? isTextColor[selectedTextColor] == .white ? Color.black.opacity(0.8) : Color.white.opacity(0.8) : Color.clear)
                .shadow(radius: 5)
                .cornerRadius(15)
                .scaleEffect(scale)
                .rotationEffect(rotation)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: true, vertical: true)
                .offset(textPosition)
        }
            .frame(width: frameSize.width, height: frameSize.height)
            .padding(.bottom, 60)
        )

        Task {
            if let uiImage = await renderer.renderUIImage() {
                savedImage = uiImage
                print("이미지가 성공적으로 저장되었습니다!")

                if let image = savedImage {
                    photoImageStore.UploadImage(image: image, imageName: id)
                    resetState() // 업로드 후 상태 초기화
                }
            } else {
                print("이미지 저장 실패")
            }
        }
    }
}

struct ImageRenderers<Content: View> {
    let content: Content

    @MainActor
    func renderUIImage() async -> UIImage? {
        let controller = UIHostingController(rootView: content)
        let view = controller.view

        // 렌더링 영역 크기
        let targetSize = CGSize(width: 360, height: 480)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .black // 배경 투명 설정

        // 레이아웃 강제 업데이트
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}
