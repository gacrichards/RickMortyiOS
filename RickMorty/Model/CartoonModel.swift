//
//  CartoonModel.swift
//  RickMorty
//
//  Created by Cole Richards on 8/20/22.
//
import Foundation

struct CartoonApiResult: Decodable {
    let info: ApiMeta
    let results: [Cartoon]
}

struct Cartoon: Decodable, Identifiable {
    let id: Int
    let name: String
    let image: String
}

struct ApiMeta: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
