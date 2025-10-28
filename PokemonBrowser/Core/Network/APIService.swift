//
//  APIService.swift
//  PokemonBrowser
//
//  Created by macbook on 26/10/25.
//

import Foundation
import Alamofire
import RxSwift

class APIService {
    static let shared = APIService()
    private let baseURL = "https://pokeapi.co/api/v2/"
    
    func fetchPokemonList(limit: Int, offset: Int) -> Observable<PokemonListResponse> {
        return Observable.create { observer in
            let url = "\(self.baseURL)pokemon"
            let parameters: [String: Any] = ["limit": limit, "offset": offset]
            
            let request = AF.request(url, parameters: parameters)
                .validate()
                .responseDecodable(of: PokemonListResponse.self) { response in
                    switch response.result {
                    case .success(let pokemonResponse):
                        observer.onNext(pokemonResponse)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func fetchPokemonDetail(name: String) -> Observable<PokemonDetail> {
        return Observable.create { observer in
            let url = "\(self.baseURL)pokemon/\(name.lowercased())"
            
            let request = AF.request(url)
                .validate()
                .responseDecodable(of: PokemonDetail.self) { response in
                    switch response.result {
                    case .success(let pokemonDetail):
                        observer.onNext(pokemonDetail)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
