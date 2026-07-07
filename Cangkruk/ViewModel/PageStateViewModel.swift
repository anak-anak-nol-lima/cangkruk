//
//  PageStateViewModel.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 07/07/26.
//

import SwiftUI

enum PageState {
    case home, detail
}


@MainActor
@Observable
class PageStateViewModel {
    var currentPage: PageState = .home
    
    func setPage(_ page: PageState) {
        currentPage = page
    }
}
