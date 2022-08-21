//
//  CartoonDao.swift
//  RickMorty
//
//  Created by Cole Richards on 8/20/22.
//

protocol CartoonDao {
    func fetchCartoons(at: Int, completion: @escaping ([Cartoon]?) -> Void)
}

class CartoonRemoteSource: CartoonDao {
    
    private let gateway = ApiGateway()
    
    func fetchCartoons(at index: Int, completion: @escaping ([Cartoon]?) -> Void) {
        let resource = RemoteResources.getCartoons(at: index)
        gateway.load(resource){ response in
            switch response {
            case .success(let cartoonApiResponse):
                completion(cartoonApiResponse.results)
            case .clientError(let failure),
                    .serverError(let failure),
                    .authorizationError(let failure),
                    .networkError(let failure):
                print(failure.message)
                completion(nil)
                
            }
        }
    }
}
