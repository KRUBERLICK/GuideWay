//
//  PresentationUtils.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/22/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import UIKit

extension String {
    subscript(i: Int) -> Character {
        return self[characters.index(startIndex, offsetBy: i)]
    }

    subscript(i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript(r: Range<Int>) -> String {
        return substring(with: characters.index(startIndex, offsetBy: r.lowerBound)
            ..< characters.index(startIndex, offsetBy: r.upperBound))
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1) {
        let length = hexString.characters.count

        strtoul(hexString, nil, 16)

        let r = CGFloat(strtoul(hexString[length - 6 ..< length - 4], nil, 16)) / 255
        let g = CGFloat(strtoul(hexString[length - 4 ..< length - 2], nil, 16)) / 255
        let b = CGFloat(strtoul(hexString[length - 2 ..< length], nil, 16)) / 255

        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
