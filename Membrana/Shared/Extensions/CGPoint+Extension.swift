//
//  CGPoint+Extension.swift
//  Membrana
//
//  Created by Fedor Bebinov on 14.12.22.
//

import Foundation

extension CGPoint {
   private func cgPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }

    func cgPointDistance(to: CGPoint) -> CGFloat {
        return sqrt(cgPointDistanceSquared(from: self, to: to))
    }
}



