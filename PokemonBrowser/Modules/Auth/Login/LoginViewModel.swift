//
//  LoginViewModel.swift
//  PokemonBrowser
//
//  Created by macbook on 28/10/25.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    
    private let db = DatabaseManager.shared
    private let disposeBag = DisposeBag()

    let email = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let loginButtonTapped = PublishRelay<Void>()
    
    let isLoggingIn = PublishRelay<Bool>()
    
    lazy var loginResult: Observable<Bool> = {
        return loginButtonTapped
            .withLatestFrom(Observable.combineLatest(email, password))
            .flatMapLatest { [weak self] (email, password) -> Observable<Bool> in
                
                guard let self = self else { return .just(false) }
                
                self.isLoggingIn.accept(true)
                let success = self.db.loginUser(userEmail: email, userPass: password)
                self.isLoggingIn.accept(false)
                
                return .just(success)
            }
            .share()
    }()

}
