//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 09.10.2022.
//

import Foundation
import UIKit

extension UIView {
    func firstParentWithClassName(_ name: String) -> UIView? {
        if name == className {
            return self
        }
        return superview?.firstParentWithClassName(name)
    }
}

extension NSObject {
    var className: String {
        return NSStringFromClass(type(of: self))
    }
}
