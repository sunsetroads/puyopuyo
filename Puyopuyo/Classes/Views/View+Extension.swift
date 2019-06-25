//
//  View+Extension.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

public protocol MeasureHolder {
//    func py_getMeasure() -> Measure
    var py_measure: Measure { get }
}


extension UIView: MeasureHolder {

    public var py_measure: Measure {
        return MeasureBox.getMeasure(from: self)
    }
}

extension UIView: MeasureTagetable {
    public var py_size: CGSize {
        get {
            return bounds.size
        }
        set {
            bounds.size = newValue
        }
    }
    
    public var py_center: CGPoint {
        get {
            return center
        }
        set {
            center = newValue
        }
    }
    
    public var py_children: [Measure] {
        return subviews.map({ $0.py_measure })
    }
    
    public var py_wrapSize: CGSize {
        get {
            sizeToFit()
            return bounds.size
        }
    }
    
    public func py_sizeThatFits(_ size: CGSize) -> CGSize {
        return sizeThatFits(size)
    }
    
}
