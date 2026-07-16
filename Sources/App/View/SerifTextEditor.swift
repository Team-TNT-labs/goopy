//
//  SerifTextEditor.swift
//  goopy
//
//  UITextView 기반 텍스트 에디터.
//  SwiftUI TextEditor는 한글 IME 조합(marked text) 중 커스텀 폰트를
//  유지하지 못해 serif/sans-serif가 깜빡이는 버그가 있음.
//
//  UIKit은 선택 변경·텍스트 전체 삭제·프로그램적 text 대입·IME 조합 커밋 시
//  typingAttributes를 임의로 리셋한다. 생성 시 1회 설정만으로는 부족하므로,
//  조합 중(markedTextRange != nil)이 아닐 때마다 폰트 불변식을 재강제한다.
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
        // Coordinator가 들고 있는 parent는 구조체 복사본이므로 최신 값으로 동기화
        context.coordinator.parent = self

        // 외부(로드 등)에서 text가 바뀐 경우에만 반영.
        // 조합 중에는 uiView.text == text 이므로 건드리지 않아 IME를 방해하지 않음.
        if uiView.text != text {
            uiView.text = text
            enforceFontInvariant(on: uiView)
        }
        if uiView.font != font {
            uiView.font = font
            enforceFontInvariant(on: uiView)
        }
        if uiView.textColor != textColor {
            uiView.textColor = textColor
            enforceFontInvariant(on: uiView)
        }
        if isFirstResponder, !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        }
    }

    /// 조합 중이 아닐 때 typingAttributes를 재강제하고,
    /// 잘못된 폰트로 커밋된 구간이 있으면 전체를 정규화한다(self-healing).
    func enforceFontInvariant(on textView: UITextView) {
        guard textView.markedTextRange == nil else { return }

        textView.typingAttributes = [
            .font: font,
            .foregroundColor: textColor
        ]

        guard let attributed = textView.attributedText, attributed.length > 0 else { return }

        var needsNormalization = false
        attributed.enumerateAttribute(.font, in: NSRange(location: 0, length: attributed.length)) { value, _, stop in
            if (value as? UIFont)?.fontName != font.fontName {
                needsNormalization = true
                stop.pointee = true
            }
        }

        if needsNormalization {
            let selectedRange = textView.selectedRange
            textView.font = font
            textView.textColor = textColor
            // selectedRange 재설정은 textViewDidChangeSelection을 한 번 더 발화시키지만,
            // 두 번째 호출에서는 needsNormalization이 false라 즉시 종료된다 (재귀 깊이 최대 2).
            textView.selectedRange = selectedRange
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
            parent.enforceFontInvariant(on: textView)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            // UIKit이 선택 변경 시 typingAttributes를 리셋하는 경우를 방어
            parent.enforceFontInvariant(on: textView)
        }
    }
}
