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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                        isDisplayTextEditor.toggle()
                    }
                    .zIndex(3)
                
                VStack {
                    Spacer() // 키보드 감지 전 공간
                    
                    VStack {
                        TextEditor(text: $editPhotoService.textInput)
                            .cornerRadius(15)
                            .padding(.horizontal, 5)
                            .foregroundColor(Color.white)
                            .frame(width: 300, height: textEditorHeight)
                            .scrollContentBackground(.hidden)
                            .background(Color.gray.opacity(0.5))
                            .zIndex(2)
                            .onChange(of: editPhotoService.textInput) { _, _ in
                                adjustHeight() // 높이 조정
                            }
                    }
                    .frame(maxHeight: keyboardHeight > 0 ? 300 : .infinity) // 키보드 높이에 따라 축소
                    
                    VStack {
                        HStack(alignment: .center, spacing: 10) {
                            Button {
                                // 색상 변경
                            } label: {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 30, height: 30)
                            }
                            
                            Button {
                                // 배경 on/off
                            } label: {
                                Text("배경")
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
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
                adjustHeight()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // 초기화
                        editPhotoService.textInput = ""
                    } label: {
                        Text("Reset")
                            .padding(.horizontal, 20) // 좌우 패딩을 추가하여 크기 조정
                            .padding(.vertical, 10) // 상하 패딩을 추가하여 버튼 높이 설정
                            .background(.accent) // 배경 색상 설정
                            .foregroundColor(.white) // 텍스트 색상 설정
                            .cornerRadius(15) // 둥근 모서리 적용
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // 저장
                        isDisplayTextEditor = false
                        // 저장 로직 추가 가능
                    } label: {
                        Text("Save")
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
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 16)]
        let boundingBox = editPhotoService.textInput.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        textEditorHeight = max(50, boundingBox.height + 24) // 기본 높이 보장
    }
}

//#Preview {
//    TextEditorView()
//}
