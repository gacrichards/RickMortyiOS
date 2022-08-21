//
//  CartoonViewModel.swift
//  RickMorty
//
//  Created by Cole Richards on 8/19/22.
//

import Combine
import Foundation

class CartoonViewModel: ObservableObject {
    @Published var cartoons: [Cartoon] = []
    private let cartoonDao: CartoonDao = CartoonRemoteSource()
    private var page: Int = 0
    
    func loadMore(){
        cartoonDao.fetchCartoons(at: page){ [weak self] newData in
            guard let safeNewData = newData else { return }
            self?.cartoons.append(contentsOf: safeNewData)
            self?.page += 1
        }
    }
}
