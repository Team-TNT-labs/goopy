//
//  SerifTextEditor.swift
//  goopy
//
//  UITextView 기반 텍스트 에디터.
//  SwiftUI TextEditor는 한글 IME 조합(marked text) 중 커스텀 폰트를
//  유지하지 못해 serif/sans-serif가 깜빡이는 버그가 있음.
//  typingAttributes에 폰트를 명시적으로 심어 조합 중에도 serif를 유지한다.
//

import SwiftUI
import UIKit

struct SerifTextEditor: UIViewRepresentable {
    @Binding var text: String
    var isFirstResponder: Bool
    var font: UIFont
    var textColor: UIColor

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = font
        textView.textColor = textColor
        textView.backgroundColor = .clear
        // marked text(조합 중 글자)에도 커스텀 폰트가 적용되도록 명시
        textView.typingAttributes = [
            .font: font,
            .foregroundColor: textColor
        ]
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.spellCheckingType = .no
        textView.allowsEditingTextAttributes = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.text = text
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        // 외부(로드 등)에서 text가 바뀐 경우에만 반영.
        // 조합 중에는 uiView.text == text 이므로 건드리지 않아 IME를 방해하지 않음.
        if uiView.text != text {
            uiView.text = text
            // .text 대입은 typingAttributes를 초기화하므로 폰트를 재적용
            uiView.typingAttributes = [
                .font: font,
                .foregroundColor: textColor
            ]
        }
        if uiView.font != font {
            uiView.font = font
        }
        if uiView.textColor != textColor {
            uiView.textColor = textColor
            uiView.typingAttributes[.foregroundColor] = textColor
        }
        if isFirstResponder, !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: SerifTextEditor

        init(_ parent: SerifTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            // 바인딩을 갱신해도 updateUIView가 uiView.text를 다시 대입하지 않으므로
            // (text 값이 같음) IME 조합이 끊기지 않는다. 조합 중에도 갱신해
            // 마지막 조합 글자가 유실되지 않게 한다.
            parent.text = textView.text
        }
    }
}
