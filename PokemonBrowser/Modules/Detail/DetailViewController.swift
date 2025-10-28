//
//  DetailViewController.swift
//  PokemonBrowser
//
//  Created by macbook on 26/10/25.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD
import Kingfisher

class DetailViewController: UIViewController {
    
    private let viewModel: DetailViewModel
    private let disposeBag = DisposeBag()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let abilitiesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.text = "Abilities:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let abilitiesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let pokemonImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .systemGray6
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        return iv
    }()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.viewDidLoad.accept(())
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(pokemonImageView)
        view.addSubview(nameLabel)
        view.addSubview(abilitiesLabel)
        view.addSubview(abilitiesStackView)
        
        NSLayoutConstraint.activate([
            pokemonImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            pokemonImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pokemonImageView.heightAnchor.constraint(equalToConstant: 160),
            pokemonImageView.widthAnchor.constraint(equalToConstant: 160),
            
            nameLabel.topAnchor.constraint(equalTo: pokemonImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            abilitiesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30),
            abilitiesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            abilitiesStackView.topAnchor.constraint(equalTo: abilitiesLabel.bottomAnchor, constant: 10),
            abilitiesStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            abilitiesStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func bindViewModel() {
        viewModel.pokemonName
            .drive(nameLabel.rx.text)
            .disposed(by: disposeBag)
            
        viewModel.abilities
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] abilities in
                self?.updateAbilitiesStack(abilities)
            })
            .disposed(by: disposeBag)
            
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.imageURL
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] url in
                let placeholder = UIImage(systemName: "questionmark.circle.fill")
                
                self?.pokemonImageView.kf.setImage(
                    with: url,
                    placeholder: placeholder,
                    options: [
                        .transition(.fade(0.3))
                    ]
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func updateAbilitiesStack(_ abilities: [String]) {
        abilitiesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for ability in abilities {
            let label = UILabel()
            label.text = "- \(ability)"
            label.font = .systemFont(ofSize: 16)
            abilitiesStackView.addArrangedSubview(label)
        }
    }
}
