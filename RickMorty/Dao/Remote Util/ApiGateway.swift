//
//  ApiGateway.swift
//  RickMorty
//
//  Created by Cole Richards on 8/20/22.
//

import Foundation

enum RequestType: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
}

enum ApiResponse<ResourceType> {
    case success(_ response: ResourceType)
    case serverError(_ error: ApiRequestFailure)
    case clientError(_ error: ApiRequestFailure)
    case authorizationError(_ error: ApiRequestFailure)
    case networkError(_ error: ApiRequestFailure)
}

struct ApiRequestFailure {
    let code: Int
    let message: String
}

public class ApiGateway: NSObject {
    static let requestTimeout: TimeInterval = 60.0
    
    private func session() -> URLSession {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
    }
    
   
    func load<ResourceType: Decodable, ParameterType: Encodable>(_ resource: Resource<ResourceType, ParameterType>, completion: @escaping (ApiResponse<ResourceType>) -> Void ){
        guard let request = urlRequest(for: resource) else {fatalError("couldn't form request")}
        let sesh = session()
        sesh.dataTask(with: request) { [unowned self] (data, response, error) in
            self.handleTaskCompletion(for: resource, data: data, response: response, error: error, completion: completion)
            }.resume()
        sesh.finishTasksAndInvalidate()
    }
    
    private func handleTaskCompletion<ResourceType: Decodable, ParameterType: Encodable>(for resource: Resource<ResourceType, ParameterType>, data: Data?, response: URLResponse?, error: Error?, completion: @escaping (ApiResponse<ResourceType>) -> Void){
        guard error == nil else {
            print(error?.localizedDescription)
            self.runOnUIThread(completion, param: ApiResponse<ResourceType>.networkError(ApiRequestFailure(code: 0, message: error!.localizedDescription)));
            return
        }
        guard let usableResponse = response as? HTTPURLResponse else {
            self.runOnUIThread(completion, param: ApiResponse<ResourceType>.networkError(ApiRequestFailure(code: 0, message: "http response unavailable")));
            return
        }
        guard let safeData = data else {
            self.runOnUIThread(completion, param: ApiResponse<ResourceType>.networkError(ApiRequestFailure(code: 0, message: "response data unavailable")));
            return
        }
        
        switch (usableResponse.statusCode) {
        case 200...299:
            print("horray a 200 response from a network call!")
            print(String(data:safeData, encoding: .utf8) ?? "failed to unwrap data packet into json string")
            if let convertedResponse = resource.responseConverter(safeData) {
                self.runOnUIThread(completion, param: ApiResponse<ResourceType>.success(convertedResponse))
            } else {
                print("failed to convert request's response")
                self.runOnUIThread(completion, param: ApiResponse<ResourceType>.clientError(ApiRequestFailure(code: usableResponse.statusCode, message: String(data: safeData, encoding: .utf8) ?? "general error")))
            }
        case 401:
            self.runOnUIThread(completion, param: ApiResponse<ResourceType>.authorizationError(ApiRequestFailure(code: usableResponse.statusCode, message: String(data: safeData, encoding: .utf8) ?? "general client error")))
        case 400...499:
            print(usableResponse)
            print(String(data: safeData, encoding: .utf8))
            self.runOnUIThread(completion, param: ApiResponse<ResourceType>.authorizationError(ApiRequestFailure(code: usableResponse.statusCode, message: String(data: safeData, encoding: .utf8) ?? "general client error")))
        case 500...599:
            print(usableResponse)
            print(String(data: safeData, encoding: .utf8))
            self.runOnUIThread(completion, param: ApiResponse<ResourceType>.serverError(ApiRequestFailure(code: usableResponse.statusCode, message: String(data: safeData, encoding: .utf8) ?? "general server error")))
        default:
            self.runOnUIThread(completion, param: ApiResponse<ResourceType>.clientError(ApiRequestFailure(code: usableResponse.statusCode, message: String(data: safeData, encoding: .utf8) ?? "general error")))
        }
    }
    
    private func urlRequest<ResourceType: Decodable, ParameterType: Encodable>(for resource: Resource<ResourceType, ParameterType>) -> URLRequest?  {
        var unsafeUrl = URL(string: resource.path)
        var components = URLComponents()
        components.scheme = unsafeUrl?.scheme
        components.host = unsafeUrl?.host
        components.path = unsafeUrl?.path ?? ""
        resource.queryParams.forEach { param in
            let queryItems = URLQueryItem(name: param.name, value: param.value)
            components.queryItems = [queryItems]
            unsafeUrl = components.url
        }
        guard let url = unsafeUrl else { return nil }
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: ApiGateway.requestTimeout)

        urlRequest.allowsCellularAccess = true
        urlRequest.httpMethod = resource.method
//        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let safeBody = resource.body {
            do {
                urlRequest.httpBody = try JSONEncoder().encode(safeBody)
            } catch {
                return nil
            }
        }
        print("made request: \(urlRequest)")
        print("request headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
        return urlRequest
    }

    private func runOnUIThread<T>(_ completion: @escaping (T) -> Void, param: T) {
        DispatchQueue.main.async {
            completion(param)
        }
    }
}

extension ApiGateway: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("got the response")
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data){
        print("got the data")
    }
}
