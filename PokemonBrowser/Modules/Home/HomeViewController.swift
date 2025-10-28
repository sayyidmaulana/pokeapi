//
//  HomeViewController.swift
//  PokemonBrowser
//
//  Created by macbook on 26/10/25.
//

import UIKit
import RxSwift
import RxCocoa
import XLPagerTabStrip
import MBProgressHUD

class HomeViewController: UIViewController, IndicatorInfoProvider {
    
    private let viewModel = HomeViewModel()
    private let disposeBag = DisposeBag()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        viewModel.viewDidLoad.accept(())
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pokemon"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PokemonCell.self, forCellReuseIdentifier: "PokemonCell")
        tableView.allowsSelection = true
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func bindViewModel() {
        viewModel.pokemonList
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: "PokemonCell", cellType: PokemonCell.self)) { (row, element, cell) in
                cell.textLabel?.text = element.name.capitalized
            }
            .disposed(by: disposeBag)
            
        viewModel.isLoading
            .asDriver()
            .drive(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            })
            .disposed(by: disposeBag)
            
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] (cell, indexPath) in
                guard let self = self else { return }
                let lastRow = self.viewModel.pokemonList.value.count - 1
                if indexPath.row == lastRow {
                    self.viewModel.loadNextPage.accept(())
                }
            })
            .disposed(by: disposeBag)
            
        tableView.rx.modelSelected(PokemonListItem.self)
            .bind(to: viewModel.itemSelected)
            .disposed(by: disposeBag)
            
        searchController.searchBar.rx.searchButtonClicked
            .withLatestFrom(searchController.searchBar.rx.text.orEmpty)
            .bind(to: viewModel.searchTriggered)
            .disposed(by: disposeBag)
        
        viewModel.selectedPokemonName
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] pokemonName in
                self?.navigateToDetail(pokemonName: pokemonName)
            })
            .disposed(by: disposeBag)
            
        viewModel.searchResultPokemonName
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] pokemonName in
                self?.searchController.isActive = false
                self?.navigateToDetail(pokemonName: pokemonName)
            })
            .disposed(by: disposeBag)
            
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showAlert(title: "Error", message: message)
            })
            .disposed(by: disposeBag)
    }
    
    private func navigateToDetail(pokemonName: String) {
        let detailVM = DetailViewModel(pokemonName: pokemonName, repository: PokemonRepository())
        let detailVC = DetailViewController(viewModel: detailVM)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Home")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

class PokemonCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
