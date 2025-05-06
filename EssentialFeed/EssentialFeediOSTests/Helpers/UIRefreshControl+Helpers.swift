//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOSTests
//
//  Created by Evgenii Iavorovich on 5/6/25.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
