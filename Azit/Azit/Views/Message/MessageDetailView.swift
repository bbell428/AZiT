//
//  MessageDetailView.swift
//  Azit
//
//  Created by 박준영 on 11/4/24.
//

import SwiftUI
import UIKit

// 키보드 내리기 위한
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

struct CustomNavigationView<Content: View>: UIViewControllerRepresentable {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: UIHostingController(rootView: content))
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        uiViewController.setViewControllers([UIHostingController(rootView: content)], animated: false)
    }
}

struct MessageDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        CustomNavigationView {
            VStack {
                // 채팅방 상단 (dismiss를 사용하기 위한 클로저 처리)
                MessageDetailTopBar(dismissAction: { dismiss() })
                    .frame(maxHeight: 80)
                
                // 채팅방 메시지 내용
                TextMessage()
                
                // 메시지 입력 공간
                MessageField()
                    .frame(maxHeight: 50)
                    .padding(.bottom)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct MessageDetailTopBar: View {
    let dismissAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: {
                dismissAction() // dismiss: 이전 화면으로 돌아가기
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.black)
                    //Text("Custom Back")
                }
            }
            .frame(alignment: .leading)
            .padding(.leading, 20)
            
            ZStack(alignment: .center) {
                Circle()
                    .fill(.subColor3)
                    .frame(width: 60, height: 60)
                
                Text("\u{1F642}")
                    .font(.system(size: 40))
            }
            .frame(alignment: .leading)
            .padding(.leading, 10)
            
            Text("박준영")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
            
        }
    }
}

struct TextMessage: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                SendMessage()
                PostMessage()
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
}

// 받은 메시지
struct SendMessage: View {
    var body: some View {
        HStack(alignment: .top) {
            Text("\u{1F642}")
                .font(.largeTitle)
                .padding(.leading, 20)
            
            VStack {
                Text("안녕하세요")
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .frame(width: 100, height: 200, alignment: .topLeading)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            }
            .background(.accent)
            .cornerRadius(15)
            .padding(.leading, 10)
            
            VStack {
                Text("오후 1:10")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray)
                    .frame(height: 200, alignment: .bottomLeading)
                    .padding(.top, 15)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// 보낸 메시지
struct PostMessage: View {
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                Text("오후 1:10")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundStyle(Color.gray)
                    .frame(height: 20, alignment: .bottomTrailing)
                    .padding(.top, 15)
            }
            
            VStack {
                Text("안녕하세요")
                    .font(.headline)
                    .foregroundStyle(Color.black.opacity(0.5))
                    .frame(width: 100, height: 20, alignment: .topTrailing)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            }
            .background(Color.gray.opacity(0.4))
            .cornerRadius(15)
            .padding(.trailing, 30)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

// 메시지를 보내는 공간
struct MessageField: View {
    @State var text: String = ""
    
    var body: some View {
        HStack {
            TextField("친구에게 메시지 보내기", text: $text)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
            
            Button(action: {
                // 전송 버튼을 눌렀을 때의 동작을 정의합니다.
                print("메시지 전송: \(text)")
                text = "" // 메시지 전송 후 입력 필드를 비웁니다.
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.accentColor)
                    .padding()
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    MessageDetailView()
}
