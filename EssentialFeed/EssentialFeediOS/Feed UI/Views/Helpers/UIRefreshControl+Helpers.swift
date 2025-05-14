//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 5/14/25.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
