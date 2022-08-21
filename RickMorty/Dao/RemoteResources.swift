//
//  RemoteResources.swift
//  RickMorty
//
//  Created by Cole Richards on 8/20/22.
//

fileprivate let root = "https://rickandmortyapi.com/api"

class RemoteResources {
    static func getCartoons(at index: Int) -> Resource<CartoonApiResult, Empty> {
        return Resource<CartoonApiResult, Empty>(method:RequestType.get.rawValue , path: "\(root)/character", queryParams: [QueryItem(name: "page", value: "\(index)")])
    }
}
