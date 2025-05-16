//
//  HTTPURLResponse+StatusCode.swift
//  EssentialFeed
//
//  Created by Evgenii Iavorovich on 5/16/25.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { 200 }
    
    var isOk: Bool {
        self.statusCode == HTTPURLResponse.OK_200
    }
}
