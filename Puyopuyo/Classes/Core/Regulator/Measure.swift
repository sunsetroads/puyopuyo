//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import UIKit

public protocol MeasureDelegate: AnyObject {
    var py_size: CGSize { get set }

    var py_center: CGPoint { get set }

    func enumerateChild(_ block: (Measure) -> Void)

    func py_sizeThatFits(_ size: CGSize) -> CGSize

    func py_setNeedsRelayout()
}

public extension MeasureDelegate {
    var isZero: Bool { py_center == .zero && py_size == .zero }
}

/// 描述一个节点相对于父节点的属性
public class Measure {
    /// 虚拟目标计算节点
    var virtualDelegate = VirtualTarget()

    /// 真实计算节点
    public weak var delegate: MeasureDelegate?

    public init(delegate: MeasureDelegate? = nil, children: [Measure] = []) {
        self.delegate = delegate
        virtualDelegate.children = children
    }

    /// 计算节点外边距
    public var margin = UIEdgeInsets.zero {
        didSet {
            if oldValue != margin {
                py_setNeedsRelayout()
            }
        }
    }

    /// 计算节点偏移
    public var alignment: Alignment = .none {
        didSet {
            if oldValue != alignment {
                py_setNeedsRelayout()
            }
        }
    }

    /// 计算节点大小描述
    public var size = Size(width: .wrap, height: .wrap) {
        didSet {
            if oldValue != size {
                py_setNeedsRelayout()
            }
        }
    }

    /// 只有在flowbox中生效
    public var flowEnding = false {
        didSet {
            if oldValue != flowEnding {
                py_setNeedsRelayout()
            }
        }
    }

    /// 是否激活本节点
    public var activated = true {
        didSet {
            if oldValue != activated {
                py_setNeedsRelayout()
            }
        }
    }

    public func calculate(by size: CGSize) -> CGSize {
        return MeasureCalculator.calculate(measure: self, residual: size)
    }

    public var diagnosisId: String?

    public var extraDiagnosisMessage: String?

    public var diagnosisMessage: String {
        """
        [\(type(of: self)), delegate: \(getRealDelegate())]
        - id: [\(diagnosisId ?? "")]
        - extra: [\(extraDiagnosisMessage ?? "")]
        - size: [width: \(size.width), height: \(size.height)]
        - alignment: [\(alignment)]
        - margin: [top: \(margin.top), left: \(margin.left), bottom: \(margin.bottom), right: \(margin.right)]
        - flowEnding: [\(flowEnding)]
        """
    }

    public var calculatedSize: CGSize = .zero

    public var calculatedCenter: CGPoint = .zero

    var sizeChanged: Bool {
        getRealDelegate().py_size != calculatedSize
    }

    var centerChanged: Bool {
        getRealDelegate().py_center != calculatedCenter
    }

    public func applyCalculatedPosition() {
        applyCalculatedCenter()
        applyCalculatedSize()
    }

    public func applyCalculatedCenter() {
        getRealDelegate().py_center = calculatedCenter
    }

    public func applyCalculatedSize() {
        getRealDelegate().py_size = calculatedSize
    }

    public func enumerateChild(_ block: (Measure) -> Void) {
        getRealDelegate().enumerateChild(block)
    }

    public func sizeThatFits(_ size: CGSize) -> CGSize {
        return getRealDelegate().py_sizeThatFits(size)
    }

    func getRealDelegate() -> MeasureDelegate {
        if let target = delegate {
            return target
        }
        return virtualDelegate
    }

    public func py_setNeedsRelayout() {
        getRealDelegate().py_setNeedsRelayout()
    }
}

class VirtualTarget: MeasureDelegate {
    var py_size: CGSize = .zero

    var py_center: CGPoint = .zero

    func enumerateChild(_ block: (Measure) -> Void) {
        children.forEach(block)
    }

    func py_sizeThatFits(_ size: CGSize) -> CGSize {
        return size
    }

    var children = [Measure]()

    func py_setNeedsRelayout() {}
}
