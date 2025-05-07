//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Evgenii Iavorovich on 5/7/25.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell> () -> T {
        let identifier = String(describing: T.self)
        return self.dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
