//
//  PokemonRepository.swift
//  PokemonBrowser
//
//  Created by macbook on 26/10/25.
//

import Foundation
import RxSwift

class PokemonRepository {
    private let apiService = APIService.shared
    
    func getPokemonList(limit: Int, offset: Int) -> Observable<[PokemonListItem]> {
        return apiService.fetchPokemonList(limit: limit, offset: offset)
            .map { $0.results }
    }
    
    func getPokemonDetail(name: String) -> Observable<PokemonDetail> {
        return apiService.fetchPokemonDetail(name: name)
    }
}
