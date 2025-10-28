//
//  RegisterViewModel.swift
//  PokemonBrowser
//
//  Created by macbook on 28/10/25.
//

import Foundation
import RxSwift
import RxCocoa

class RegisterViewModel {
    let db = DatabaseManager.shared
    let disposeBag = DisposeBag()
    
    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let registerButtonTapped = PublishRelay<Void>()
    
    let isRegistering = PublishRelay<Bool>()
    
    lazy var registrationResult: Observable<Bool> = {
        return registerButtonTapped
            .withLatestFrom(Observable.combineLatest(email, password))
            .flatMapLatest { [weak self] (email, password) -> Observable<Bool> in
                
                guard let self = self else { return .just(false) }
                
                self.isRegistering.accept(true)
                let success = self.db.registerUser(userEmail: email, userPass: password)
                self.isRegistering.accept(false)
                
                return .just(success)
            }
            .share()
    }()
}
