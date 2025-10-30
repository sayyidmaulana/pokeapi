//
//  MainPagerViewController.swift
//  PokemonBrowser
//
//  Created by macbook on 26/10/25.
//

import UIKit
import XLPagerTabStrip

class MainPagerViewController: ButtonBarPagerTabStripViewController {

    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var homeVC: HomeViewController = {
        let vc = HomeViewController()
        vc.searchController = self.searchController
        return vc
    }()
    
    private lazy var profileVC: ProfileViewController = {
        return ProfileViewController()
    }()

    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = .systemBlue
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        self.title = "Pokédex"
        
        self.edgesForExtendedLayout = []
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        setupSearchController()
        
        super.viewDidLoad()
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .gray
            newCell?.label.textColor = .systemBlue
        }
    }
    
    private func setupSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Pokemon"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return [homeVC, profileVC]
    }
    
    override func updateIndicator(for viewController: PagerTabStripViewController, fromIndex: Int, toIndex: Int) {
        super.updateIndicator(for: viewController, fromIndex: fromIndex, toIndex: toIndex)
        
        if toIndex == 0 {
            navigationItem.searchController = searchController
        } else {
            navigationItem.searchController = nil
        }
    }
}
