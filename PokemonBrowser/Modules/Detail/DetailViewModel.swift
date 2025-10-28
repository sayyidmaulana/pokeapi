//
//  DetailViewModel.swift
//  PokemonBrowser
//
//  Created by macbook on 26/10/25.
//

import Foundation
import RxSwift
import RxCocoa

class DetailViewModel {
    private let repository: PokemonRepository
    private let disposeBag = DisposeBag()
    
    let viewDidLoad = PublishRelay<Void>()
    
    let pokemonName: Driver<String>
    let abilities = BehaviorRelay<[String]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    let imageURL = PublishRelay<URL?>()
    
    init(pokemonName: String, repository: PokemonRepository) {
        self.repository = repository
        
        self.pokemonName = Driver.just(pokemonName.capitalized)
        
        viewDidLoad
            .flatMapLatest { [weak self] _ -> Observable<PokemonDetail> in
                guard let self = self else { return .empty() }
                self.isLoading.accept(true)
                return self.repository.getPokemonDetail(name: pokemonName)
                    .catch { [weak self] error in
                        self?.isLoading.accept(false)
                        self?.errorMessage.accept(error.localizedDescription)
                        return .empty()
                    }
            }
            .subscribe(onNext: { [weak self] detail in
                self?.isLoading.accept(false)
                let abilityNames = detail.abilities.map { $0.ability.name.capitalized }
                self?.abilities.accept(abilityNames)
                
                if let urlString = detail.sprites.frontDefault {
                    self?.imageURL.accept(URL(string: urlString))
                } else {
                    self?.imageURL.accept(nil)
                }
            })
            .disposed(by: disposeBag)
    }
}
