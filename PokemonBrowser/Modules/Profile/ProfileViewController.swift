//
//  ProfileViewController.swift
//  PokemonBrowser
//
//  Created by macbook on 26/10/25.
//

import UIKit
import XLPagerTabStrip

class ProfileViewController: UIViewController, IndicatorInfoProvider {

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
        
        logoutButton.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [emailLabel, logoutButton])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadUserData() {
        if let email = UserDefaults.standard.string(forKey: "loggedInUserEmail") {
            emailLabel.text = "Logged in as: \(email)"
        }
    }
    
    @objc private func handleLogout() {
        UserDefaults.standard.removeObject(forKey: "loggedInUserEmail")
        
        guard let window = view.window else { return }
        let loginVC = LoginViewController()
        let rootNC = UINavigationController(rootViewController: loginVC)
        
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = rootNC
        }, completion: nil)
    }

    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Profile")
    }
}
