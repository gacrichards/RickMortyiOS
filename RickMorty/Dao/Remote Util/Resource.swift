//
//  ApiResource.swift
//  RickMorty
//
//  Created by Cole Richards on 8/20/22.
//

import Foundation

struct Empty: Codable {}

struct QueryItem {
    let name: String
    let value: String
}

class Resource<ResourceType: Decodable, ParameterType:Encodable> {
    let method: String
    let path: String
    var body: ParameterType?
    var queryParams: [QueryItem]
    
    private(set) var success: ((ResourceType)->())?
    private(set) var failure: ((Error)->())?
    var responseConverter: (Data)->(ResourceType?)
    
    init(method: String, path: String, queryParams: [QueryItem] = []){
        self.method = method
        self.path = path
        self.queryParams = queryParams
        self.responseConverter = { data in
            do {
                return try JSONDecoder().decode(ResourceType.self, from: data)
            } catch {
                print(error)
                return nil
            }
        }
    }
    
    func bodyData()->Data? {
        do {
            return try JSONEncoder().encode(body)
        } catch {
            return nil
        }
    }

    func success(_ completion: ((ResourceType) -> ())? ) -> Resource{
        success = completion
        return self
    }
    
    func failure(_ failure: ((Error)-> ())? ) -> Resource{
        self.failure = failure
        return self
    }
}
