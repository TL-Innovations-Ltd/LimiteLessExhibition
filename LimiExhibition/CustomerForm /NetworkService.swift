//
//  NetworkService.swift
//  Limi
//
//  Created by Mac Mini on 05/04/2025.
//


import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    
    private init() {}
    
    func sendData(payload: [String: Any], completion: @escaping (Result<Any, Error>) -> Void) {
        guard let url = URL(string: "https://contemporary-lesson-victoria-checkout.trycloudflare.com/client/customer_capture") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            print("\(payload)")
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                completion(.success(json))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .noData:
            return "No data received from server"
        }
    }
}
