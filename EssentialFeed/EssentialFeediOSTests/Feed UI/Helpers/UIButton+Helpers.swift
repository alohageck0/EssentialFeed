//
//  UIButton+Helpers.swift
//  EssentialFeediOSTests
//
//  Created by Evgenii Iavorovich on 5/6/25.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
