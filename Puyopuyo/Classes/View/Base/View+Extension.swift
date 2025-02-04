//
//  View+Extension.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/23.
//

import Foundation

public extension UIView {
    private static var measureHoldingKey = "measureHoldingKey"
    var py_measure: Measure {
        var measure = objc_getAssociatedObject(self, &UIView.measureHoldingKey) as? Measure
        if measure == nil {
            if let regulatable = self as? RegulatorView {
                measure = regulatable.createRegulator()
            } else {
                measure = Measure(delegate: self)
            }
            objc_setAssociatedObject(self, &UIView.measureHoldingKey, measure, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return measure!
    }
}

// MARK: - MeasureTargetable impl

extension UIView: MeasureDelegate {
    public func children(for measure: Measure) -> [Measure] {
        subviews.map { $0.py_measure }
    }

    public func measure(_ measure: Measure, sizeThatFits size: CGSize) -> CGSize {
        sizeThatFits(size)
    }

    public func needsRelayout(for measure: Measure) {
        if BoxUtil.isBox(superview) {
            superview?.setNeedsLayout()
        }
        setNeedsLayout()
    }

    func py_setNeedsRelayout() {
        needsRelayout(for: py_measure)
    }

    func py_setNeedsLayoutIfMayBeWrap() {
        if py_measure.size.maybeWrap() {
            py_setNeedsRelayout()
        }
    }
}

// MARK: - UIView ext methods

public extension UIView {
    private static var py_animatorKey = "py_animatorKey"
    var py_animator: Animator? {
        set {
            objc_setAssociatedObject(self, &UIView.py_animatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue != nil {
                py_setNeedsRelayout()
            }
        }
        get {
            objc_getAssociatedObject(self, &UIView.py_animatorKey) as? Animator
        }
    }

    var py_visibility: Visibility {
        set {
            // hidden
            switch newValue {
            case .visible, .free: isHidden = false
            default: isHidden = true
            }
            // activated
            switch newValue {
            case .visible, .invisible: py_measure.activated = true
            default: py_measure.activated = false
            }
        }
        get {
            switch (py_measure.activated, isHidden) {
            case (true, false): return .visible
            case (true, true): return .invisible
            case (false, true): return .gone
            case (false, false): return .free
            }
        }
    }

    func py_originState() -> Outputs<CGPoint> {
        py_frameState().map(\.origin).distinct()
    }

    func py_sizeState() -> Outputs<CGSize> {
        Outputs.merge([py_boundsState(), py_frameState()]).map(\.size).distinct()
    }

    func py_boundsState() -> Outputs<CGRect> {
        py_observing(\.bounds).unwrap(or: .zero).distinct()
    }

    func py_frameState() -> Outputs<CGRect> {
        py_observing(\.frame).unwrap(or: .zero).distinct()
    }

    func py_centerState() -> Outputs<CGPoint> {
        py_observing(\.center).unwrap(or: .zero).distinct()
    }

    /// ios11监听safeAreaInsets, ios10及以下，则监听frame变化并且通过转换坐标后得到与statusbar的差距
    func py_safeArea() -> Outputs<UIEdgeInsets> {
        if #available(iOS 11, *) {
            return py_observing(\.safeAreaInsets).unwrap(or: .zero).distinct()
        } else {
            // ios 11 以下只可能存在statusbar影响的safeArea
            return
                Outputs.merge([
                    py_frameState().map { _ in 1 },
                    py_centerState().map { _ in 1 },
                    py_boundsState().map { _ in 1 },
                ])
                .map { [weak self] _ -> UIEdgeInsets in
                    guard let self = self else { return .zero }
                    let newRect = self.convert(self.bounds, to: UIApplication.shared.keyWindow)
                    var inset = UIEdgeInsets.zero
                    let statusFrame = UIApplication.shared.statusBarFrame
                    inset.top = min(statusFrame.height, max(0, statusFrame.height - newRect.origin.y))
                    return inset
                }
                .distinct()
        }
    }
}

public extension Bool {
    /// return if visible or gone
    func py_visibleOrGone() -> Visibility {
        return self ? .visible : .gone
    }

    /// return if visible or invisible
    func py_visibleOrNot() -> Visibility {
        return self ? .visible : .invisible
    }

    func py_toggled() -> Bool { !self }
}

public extension UIView {
    var isPositionZero: Bool {
        bounds.size == .zero && center == .zero
    }
}
