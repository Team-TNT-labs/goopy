//
//  AppFont.swift
//  goopy
//
//  커스텀 폰트 이름의 단일 정의.
//  반드시 PostScript명을 사용한다 — 풀네임("KoPubWorldBatang_Pro Medium")은
//  OS/컨텍스트에 따라 매칭이 실패해 시스템 폰트로 폴백될 수 있다.
//  위젯 타깃은 goopyWidget.swift에 같은 상수가 별도로 있으므로 함께 변경할 것.
//

import SwiftUI
import UIKit

enum AppFont {
    /// Climate Crisis KR 1990
    static let crisis = "ClimateCrisisKR-1990"
    /// KoPubWorld 바탕체 Pro Medium
    static let kpubWorldBatang = "KoPubWorldBatangPM"
    /// 느림보고딕 Regular
    static let neurimboGothic = "neurimboGothicRegular"
}

extension Font {
    static func crisis(size: CGFloat) -> Font {
        .custom(AppFont.crisis, size: size)
    }

    static func kpubWorld(size: CGFloat) -> Font {
        .custom(AppFont.kpubWorldBatang, size: size)
    }

    static func neurimboGothic(size: CGFloat) -> Font {
        .custom(AppFont.neurimboGothic, size: size)
    }
}

extension UIFont {
    static func kpubWorld(size: CGFloat) -> UIFont {
        UIFont(name: AppFont.kpubWorldBatang, size: size) ?? .systemFont(ofSize: size)
    }
}
