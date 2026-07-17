//
//  Wavelength.swift
//  Cangkruk
//
//  Created by Joren Alexander Toding on 17/07/26.
//

import SwiftUI

struct WaveformView: View {
    let levels : [CGFloat]
    var barCount: Int = 36
    
    var body: some View {
        HStack (spacing: 3){
            ForEach(0..<barCount, id:\.self){
                i in Capsule()
                .fill(.green)
                .frame(width: 3, height: 6 + 26 * levelAt(i))
            }
        }
        .animation(.linear(duration:0.08), value: levels)
    }
    private func levelAt (_ i: Int) -> CGFloat{
        let start = max (0, levels.count - barCount)
        let idx = start + i
        return idx < levels.count ? levels[idx] : 0.05
    }
}
