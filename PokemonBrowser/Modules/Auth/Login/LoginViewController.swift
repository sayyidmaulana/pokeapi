//
//  LoginViewController.swift
//  PokemonBrowser
//
//  Created by macbook on 28/10/25.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

class LoginViewController: UIViewController {
    
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let goToRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Don't have an account? Register", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Login"
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, goToRegisterButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func bindViewModel() {
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .bind(to: viewModel.loginButtonTapped)
            .disposed(by: disposeBag)
        
        goToRegisterButton.rx.tap
                .subscribe(onNext: { [weak self] in
                    let registerVC = RegisterViewController()
                    self?.navigationController?.pushViewController(registerVC, animated: true)
                })
                .disposed(by: disposeBag)
            
            viewModel.loginResult
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] success in
                    if success {
                        UserDefaults.standard.set(self?.viewModel.email.value, forKey: "loggedInUserEmail")
                        
                        self?.goToMainApp()
                    } else {
                        self?.showAlert(title: "Error", message: "Invalid email or password.")
                    }
                })
                .disposed(by: disposeBag)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func goToMainApp() {
        guard let window = view.window else { return }
        
        let mainPagerVC = MainPagerViewController()
        let rootNC = UINavigationController(rootViewController: mainPagerVC)
        
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromRight, animations: {
            window.rootViewController = rootNC
        }, completion: nil)
    }
}
