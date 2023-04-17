//
//  String+Extension.swift
//  Membrana
//
//  Created by Fedor Bebinov on 03.04.23.
//

import Foundation

extension String {
    func isEmptyOrWhitespace() -> Bool {
        if self.isEmpty || self.trimmingCharacters(in: NSCharacterSet.whitespaces).isEmpty {
            return true
        }
        return false
    }
}
