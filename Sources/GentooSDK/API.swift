//
//  API.swift
//
//
//  Created by USER on 8/11/24.
//

import Foundation

enum APIError: Error {
    case invalidResponse
    case serverError(String)
    case decodingError
}

struct API {
    
    static let dev = API(
        chatURL: URL(string: "https://dev-demo.gentooai.com")!,
        apiURL: URL(string: "https://hg5eey52l4.execute-api.ap-northeast-2.amazonaws.com/dev")!,
        apiKey: "G4J2wPnd643wRoQiK52PO9ZAtaD6YNCAhGlfm1Oc"
    )
    
    static let prod = API(
        chatURL: URL(string: "https://demo.gentooai.com")!,
        apiURL: URL(string: "https://byg7k8r4gi.execute-api.ap-northeast-2.amazonaws.com/prod")!,
        apiKey: "EYOmgqkSmm55kxojN6ck7a4SKlvKltpd9X5r898k"
    )
    
    let chatURL: URL
    
    let apiURL: URL
    
    let apiKey: String
    
    private init(chatURL: URL, apiURL: URL, apiKey: String) {
        self.chatURL = chatURL
        self.apiURL = apiURL
        self.apiKey = apiKey
    }
    
    private let session = URLSession.shared
    
    private var authURL: URL {
        return apiURL.appendingPathComponent("/auth")
    }
    
    private var recommendURL: URL {
        return apiURL.appendingPathComponent("/recommend")
    }
    
    func fetchUserID(udid: String, authCode: String, completion: @escaping (Result<String, APIError>) -> Void) {
        var request = URLRequest(url: authURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue(udid, forHTTPHeaderField: "udid")
        request.addValue(authCode, forHTTPHeaderField: "authCode")
        
        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(.serverError(error!.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                completion(.success(authResponse.body.randomId))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func fetchComment(itemId: String, userId: String, completion: @escaping (Result<CommentResponse, APIError>) -> Void) {
        let url = recommendURL
            .appending("itemId", value: itemId)
            .appending("userId", value: userId)
        
        session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(.failure(.serverError(error!.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let commentResponse = try JSONDecoder().decode(CommentResponse.self, from: data)
                completion(.success(commentResponse))
            } catch {
                completion(.failure(.decodingError))
            }
            
        }.resume()
    }
    
    func fetchProduct(itemId: String, userId: String, target: String, completion: @escaping (Result<String, APIError>) -> Void) {
        var request = URLRequest(url: recommendURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "itemId": itemId,
            "userId": userId,
            "target": target,
            "channelId": "mobile"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(.serverError(error!.localizedDescription)))
                return
            }
            
            guard let data = data,
                  let product = String(data: data, encoding: .utf8) else {
                completion(.failure(.invalidResponse))
                return
            }
            
            completion(.success(product))
        }.resume()
    }
}

extension API {
    
    struct AuthResponse: Decodable {
        let statusCode: Int
        let body: Body
        
        struct Body: Decodable {
            let randomId: String
        }
    }
    
    struct CommentResponse: Decodable, Equatable {
        var this: String
        var needs: String
        var `case`: String
    }
    
    
}
