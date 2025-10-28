//
//  HomeViewModel.swift
//  PokemonBrowser
//
//  Created by macbook on 26/10/25.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    private let repository = PokemonRepository()
    private let disposeBag = DisposeBag()
    private var currentOffset = 0
    private let pokemonLimit = 10
    
    let viewDidLoad = PublishRelay<Void>()
    let loadNextPage = PublishRelay<Void>()
    let itemSelected = PublishRelay<PokemonListItem>()
    let searchTriggered = PublishRelay<String>()

    let pokemonList = BehaviorRelay<[PokemonListItem]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let selectedPokemonName = PublishRelay<String>()
    let searchResultPokemonName = PublishRelay<String>()
    let errorMessage = PublishRelay<String>()
    
    init() {
        bind()
    }
    
    private func bind() {
        let initialLoad = viewDidLoad
            .flatMap { [weak self] _ -> Observable<[PokemonListItem]> in
                guard let self = self else { return .empty() }
                self.isLoading.accept(true)
                self.currentOffset = 0 // Reset offset
                return self.fetchPokemon()
            }
            .do(onNext: { [weak self] _ in self?.isLoading.accept(false) })
        
        let nextPageLoad = loadNextPage
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .filter { [weak self] in self?.isLoading.value == false }
            .flatMap { [weak self] _ -> Observable<[PokemonListItem]> in
                guard let self = self else { return .empty() }
                self.isLoading.accept(true)
                return self.fetchPokemon()
            }
            .do(onNext: { [weak self] _ in self?.isLoading.accept(false) })
        
        Observable.merge(initialLoad, nextPageLoad)
            .subscribe(onNext: { [weak self] newItems in
                guard let self = self else { return }
                if self.currentOffset == self.pokemonLimit {
                    self.pokemonList.accept(newItems)
                } else {
                    self.pokemonList.accept(self.pokemonList.value + newItems)
                }
            })
            .disposed(by: disposeBag)

        itemSelected
            .map { $0.name }
            .bind(to: selectedPokemonName)
            .disposed(by: disposeBag)
            
        searchTriggered
            .filter { !$0.isEmpty }
            .flatMapLatest { [weak self] query -> Observable<PokemonDetail> in
                guard let self = self else { return .empty() }
                self.isLoading.accept(true)
                return self.repository.getPokemonDetail(name: query)
                    .catch { [weak self] error in
                        self?.isLoading.accept(false)
                        self?.errorMessage.accept("Pokemon not found")
                        return .empty()
                    }
            }
            .subscribe(onNext: { [weak self] detail in
                self?.isLoading.accept(false)
                self?.searchResultPokemonName.accept(detail.name)
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchPokemon() -> Observable<[PokemonListItem]> {
        return repository.getPokemonList(limit: pokemonLimit, offset: currentOffset)
            .do(onNext: { [weak self] items in
                if !items.isEmpty {
                    self?.currentOffset += self?.pokemonLimit ?? 10
                }
            }, onError: { [weak self] error in
                self?.errorMessage.accept(error.localizedDescription)
                self?.isLoading.accept(false)
            })
            .catchAndReturn([])
    }
}
