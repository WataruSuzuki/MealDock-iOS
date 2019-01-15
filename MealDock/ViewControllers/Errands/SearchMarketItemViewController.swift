//
//  SearchMarketItemViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki on 2018/11/20.
//  Copyright © 2018 WataruSuzuki. All rights reserved.
//

import UIKit

class SearchMarketItemViewController: ErrandViewController,
    UISearchBarDelegate
{
    var delegate: SearchMarketItemViewDelegate?
    var filteredItem = [[Harvest]]()
    var marketItems: [MarketItems]!
    let searchBar = UISearchBar(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredItem = marketItems.map({ (market) -> [Harvest] in
            return market.items
        }).reversed()
        searchBar.delegate = self
        
        navigationItem.titleView = searchBar
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(tapDismiss))
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredItem.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredItem[section].count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return errandCollection(collectionView, cellForItemAt: indexPath, item: filteredItem[indexPath.section][indexPath.row])
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(harvest: filteredItem[indexPath.section][indexPath.row], indexPath: indexPath)
    }

    // MARK: UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let inputText = searchBar.text {
            let toIndex = inputText.index(inputText.startIndex, offsetBy: range.location)
            let newText = (text.isEmpty
                ? String(inputText[..<toIndex])
                : String(inputText[..<toIndex]) + text
            )
            filteringHarvest(newText)
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteringHarvest(searchText)
    }
    
    private func filteringHarvest(_ searchBarText: String?) {
        filteredItem = marketItems.map({$0.items}).reversed()
        if let inputText = searchBarText {
            filteredItem = filteredItem.map({
                $0.filter({
                    $0.name.foodName.contains(inputText)
                })
            })
            self.collectionView?.reloadData()
        }
    }
}
