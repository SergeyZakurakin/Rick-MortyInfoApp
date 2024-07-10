//
//  NetworkManager.swift
//  RickMortyApiApp
//
//  Created by Sergey Zakurakin on 12/05/2024.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}


final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchImage(from url: URL, completion: @escaping(Result<Data, NetworkError>) -> Void) {
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else {
                completion(.failure(.noData))
                return
            }
            DispatchQueue.main.async {
                completion(.success(imageData))
            }
        }
        
    }
    
    func fetchData(from url: URL, completion: @escaping(Result<RickMorty, NetworkError>) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error ?? "No error description")
                return
            }
            do {
                let rickM = try JSONDecoder().decode(RickMorty.self, from: data)
                
                DispatchQueue.main.async  { [weak self] in
                    guard self != nil else { return }
                    completion(.success(rickM))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        } .resume()
    }
    
    
    
    
    func fetch<T: Decodable>(_ type: T.Type, from url: URL, completion: @escaping(Result<T, NetworkError>) -> Void) {
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error ?? "No error description")
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let dataModel = try decoder.decode(T.self, from: data)
                
                completion(.success(dataModel))
                
                
            } catch {
                completion(.failure(.decodingError))
            }
        } .resume()
    }
    
    
    //    func postRequest(with parameters: [String: Any], to url: URL, completion: @escaping(Result<Any, NetworkError>) -> Void) {
    //        let serializedData = try? JSONSerialization.data(withJSONObject: parameters)
    //
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "POST"
    //        request.httpBody = serializedData
    //
    //        URLSession.shared.dataTask(with: request) { data, response, error in
    //            guard let data, let response else {
    //                print(error?.localizedDescription ?? "No error description")
    //                return
    //            }
    //
    //            print(response)
    //
    //            do {
    //                let json = try JSONSerialization.jsonObject(with: data)
    //                completion(.success(json))
    //            } catch {
    //                completion(.failure(.decodingError))
    //            }
    //        }.resume()
    //
    //
    //    }
    
    func postRequest(with parameters: RickMorty, to url: URL, completion: @escaping(Result<Any, NetworkError>) -> Void) {
        guard let encodedJSON = try? JSONEncoder().encode(parameters) else {
            completion(.failure(.noData))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodedJSON
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data, let response else {
                print(error?.localizedDescription ?? "No error description")
                return
            }
            
            print(response)
            
            do {
                let model = try JSONDecoder().decode(RickMorty.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
        
    }
}
