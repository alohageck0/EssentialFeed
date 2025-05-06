//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOSTests
//
//  Created by Evgenii Iavorovich on 5/6/25.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
