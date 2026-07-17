//
//  FontExtension.swift
//  Cangkruk
//
//  Created by Stefanie Agahari on 13/07/26.
//

import SwiftUI

extension Font {
    static func shakyComicBold(size: CGFloat, relativeTo textStyle: Font.TextStyle = .title) -> Font {
        return .custom("ShakyHandSomeComic-Bold", size: size, relativeTo: textStyle)
    }
}
