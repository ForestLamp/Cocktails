//
//  NetworkRequest.swift
//  Cocktails
//
//  Created by Alex Ch. on 28.03.2022.
//

import Foundation
import Alamofire

// MARK: - NetworkServiceProtocol

protocol NetworkServiceProtocol {
    func getDrinks(completion: @escaping (Result<Drinks?, Error>) -> Void)
}

// MARK: - NetworkService

final class NetworkService: NetworkServiceProtocol {
    
    func getDrinks(completion: @escaping (Result<Drinks?, Error>) -> Void) {
        
        guard let url = URL(string: "https://www.thecocktaildb.com/api/json/v1/1/filter.php?a=Non_Alcoholic") else { return }
        
        AF.request(url, method: .get)
            .responseJSON { response in
                guard let data = response.data else { return }
                do {
                    let json = try JSONDecoder().decode(Drinks.self, from: data)
                    completion(.success(json))
                } catch {
                    
                }
            }
    }
}
