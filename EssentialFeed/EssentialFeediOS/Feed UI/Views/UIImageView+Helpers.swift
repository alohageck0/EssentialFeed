//
//  UIImageView+Helpers.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 5/7/25.
//

import UIKit

extension UIImageView {
    func setImageAminated(_ newImage: UIImage?) {
        image = newImage
        
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
