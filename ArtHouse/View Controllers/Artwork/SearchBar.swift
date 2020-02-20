//
//  SearchBar.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 2/20/20.
//  Copyright © 2020 The Scarpa Group. All rights reserved.
//

import Foundation
import UIKit

protocol SearchBarDelegate: class {
    func didSearch(for query: String)
}

class SearchBar: UICollectionReusableView, UISearchBarDelegate {

    let searchBar = UISearchBar()
    weak var delegate: SearchBarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        searchBar.placeholder = "Find something great"
        searchBar.delegate = self
        addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        searchBar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        searchBar.resignFirstResponder()
        delegate?.didSearch(for: query)
    }

}
