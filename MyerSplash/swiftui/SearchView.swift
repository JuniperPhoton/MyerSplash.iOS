//
//  SearchViewSwiftUIController.swift
//  MyerSplash
//
//  Created by JuniperPhoton on 2020/6/24.
//  Copyright © 2020 juniper. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import MyerSplashShared

@available(iOS 13.0, *)
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style = .systemMaterial
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: style))
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return v
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        //uiView.effect = UIBlurEffect(style: style)
    }
}

@available(iOS 13.0, *)
struct SearchHintSwiftUIView: UIViewRepresentable {
    var onClickKeyword: ((Keyword) -> Void)?
    
    var expectedWidth: CGFloat
    
    @Binding var height: CGFloat
    
    func makeUIView(context: Context) -> SearchHintView {
        let v = SearchHintView()
        v.onClickKeyword = self.onClickKeyword
        v.onLayout = { size in
            self.height = size.height
        }
        return v
    }
    
    func updateUIView(_ uiView: SearchHintView, context: Context) {
        // ignored
    }
}

@available(iOS 13.0, *)
struct CustomTextField: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        
        var onCommited: ((String?) -> Void)?
        var didBecomeFirstResponder = false
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            if reason == .committed {
                onCommited?(textField.text)
            }
        }
    }
    
    @Binding var text: String
    
    var placeholder: String?
    var isFirstResponder: Bool = false
    var onCommited: ((String?) -> Void)?
    
    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        return textField
    }
    
    func makeCoordinator() -> CustomTextField.Coordinator {
        let c = Coordinator(text: $text)
        c.onCommited = self.onCommited
        return c
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
}

@available(iOS 13.0, *)
struct SearchView: View {
    private let searchBarWidth = 600.cgFloat
    private let hintWidth = 760.cgFloat
    
    @State var searchContent = ""
    @State var hintHeight: CGFloat = 0
    
    var dismissAction: (() -> Void)?
    var onClickKeyword: ((Keyword) -> Void)?
    
    var predefinedKeywords: [Keyword] = SearchHintView.builtInKeywords
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(alignment: .center, spacing: 12) {
                Text(R.strings.search_title)
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .accentColor(.init(UIView.getDefaultLabelUIColor()))
                HStack(alignment: .center, spacing: 12) {
                    CustomTextField(text: self.$searchContent,
                                    placeholder: R.strings.search_hint, isFirstResponder: true,
                                    onCommited: { s in
                                        if !self.searchContent.isEmpty {
                                            self.onClickKeyword?(Keyword(displayTitle: self.searchContent, query: self.searchContent))
                                        }
                    })
                        .frame(width: self.searchBarWidth, height: 30, alignment: .leading)
                        .padding(12)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    Button(action: self.dismissAction!) {
                        Image("ic_clear")
                            .renderingMode(.template)
                            .accentColor(.init(UIView.getDefaultLabelUIColor()))
                    }.frame(width: 50, height: 50, alignment: .center)
                }
                SearchHintSwiftUIView(onClickKeyword: self.onClickKeyword,
                                      expectedWidth: self.hintWidth,
                                      height: self.$hintHeight)
                    .frame(width: self.hintWidth, height: self.hintHeight, alignment: .center)
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

@available(iOS 13.0, *)
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
