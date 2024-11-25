//
//  TextEditorView.swift
//  Azit
//
//  Created by 박준영 on 11/24/24.
//

import SwiftUI

struct TextEditorView: View {
    @Binding var isDisplayTextEditor: Bool // 이미지 편집에 들어갈 텍스트 편집 뷰
    
    @EnvironmentObject var editPhotoService: EditPhotoStore
    @State private var keyboardHeight: CGFloat = 0 // 키보드 높이를 저장할 상태 변수
    @State var textEditorHeight: CGFloat? // 초기 높이
    @State var temporaryText: String = "" // 임시저장
    @State var selectedColorIndex: Int = 0 // 선택된 색상 인덱스
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        editPhotoService.textInput = temporaryText
                        editPhotoService.selectedTextColor = selectedColorIndex
                        UIApplication.shared.endEditing()
                        isDisplayTextEditor.toggle()
                        temporaryText = ""
                        selectedColorIndex = 0
                    }
                    .zIndex(3)
                
                VStack {
                    Spacer() // 키보드 감지 전 공간
                    
                    VStack {
                        TextEditor(text: $temporaryText)
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .padding(.horizontal, 10)
                            .foregroundColor(editPhotoService.isTextColor[selectedColorIndex])
                            .frame(width: 270, height: textEditorHeight)
                            .scrollContentBackground(.hidden)
                            .background(editPhotoService.isTextColor[selectedColorIndex] == .white ? Color.black.opacity(0.8) : Color.white.opacity(0.8))
                            .cornerRadius(15)
                            .zIndex(2)
                            .onChange(of: temporaryText) { _, _ in
                                adjustHeight() // 높이 조정
                            }
                    }
                    .frame(maxHeight: keyboardHeight > 0 ? 300 : .infinity) // 키보드 높이에 따라 축소
                    
                    VStack {
                        HStack(alignment: .center, spacing: 10) {
                            Button {
                                selectedColorIndex = (selectedColorIndex + 1) % editPhotoService.isTextColor.count
                            } label: {
                                Circle()
                                    .fill(editPhotoService.isTextColor[selectedColorIndex])
                                    .frame(width: 30, height: 30)
                            }
                            
                            Button {
                                editPhotoService.isBackgroundText.toggle()
                            } label: {
                                if editPhotoService.isBackgroundText {
                                    HStack(spacing: 10) {
                                        Image(systemName: "checkmark")
                                            .padding(.leading, 10)
                                            .padding(.vertical, 10)
                                        Text("배경")
                                            .padding(.trailing, 10)
                                            .padding(.vertical, 10)
                                    }
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15) // 둥글게 만들기
                                            .fill(Color.green) // 배경색
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 15)) // 클리핑
                                } else {
                                    Text("배경")
                                        .font(.title3)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(15)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                }
                .zIndex(4)
                .frame(maxHeight: .infinity)
                .padding(.bottom, keyboardHeight > 0 ? keyboardHeight - 130 : 10) // 키보드 높이만큼 여백 추가
                .animation(.easeInOut, value: keyboardHeight) // 부드러운 애니메이션
            }
            .onAppear {
                temporaryText = editPhotoService.textInput // 불러온 값을 임시저장에 투입
                selectedColorIndex = editPhotoService.selectedTextColor // 불러온 색상값을 임시저장에 투입
                adjustHeight()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
//                    Button {
//                        // 초기화
//                        editPhotoService.textInput = ""
//                    } label: {
//                        Text("Reset")
//                            .padding(.horizontal, 20) // 좌우 패딩을 추가하여 크기 조정
//                            .padding(.vertical, 10) // 상하 패딩을 추가하여 버튼 높이 설정
//                            .background(.accent) // 배경 색상 설정
//                            .foregroundColor(.white) // 텍스트 색상 설정
//                            .cornerRadius(15) // 둥근 모서리 적용
//                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editPhotoService.textInput = temporaryText
                        temporaryText = ""
                        isDisplayTextEditor = false
                    } label: {
                        Text("Done")
                            .padding(.horizontal, 20) // 좌우 패딩을 추가하여 크기 조정
                            .padding(.vertical, 10) // 상하 패딩을 추가하여 버튼 높이 설정
                            .background(.accent) // 배경 색상 설정
                            .foregroundColor(.white) // 텍스트 색상 설정
                            .cornerRadius(15) // 둥근 모서리 적용
                    }
                }
            }
            .toolbarBackground(.black, for: .navigationBar, .tabBar)
            .onAppear {
                // 키보드 높이 감지
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        keyboardHeight = keyboardFrame.height
                    }
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            }
        }
        //.navigationBarTitle("텍스트 편집", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
    }
    
    // 텍스트 에디터 높이를 동적으로 조정하는 함수
    private func adjustHeight() {
        let width = UIScreen.main.bounds.width - 150 // 좌우 여백 포함
        let size = CGSize(width: width, height: .infinity)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 20)]
        let boundingBox = temporaryText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        textEditorHeight = max(20, boundingBox.height + 40) // 기본 높이 보장
    }
}

//#Preview {
//    TextEditorView()
//}
