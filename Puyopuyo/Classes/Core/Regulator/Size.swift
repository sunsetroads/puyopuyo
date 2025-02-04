//
//  Size.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/22.
//

import Foundation

// MARK: - SizeDescriptible

public protocol SizeDescriptible {
    var sizeDescription: SizeDescription { get }
}

extension CGFloat: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(self) } }
extension Double: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension Float: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension Int: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension UInt: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension Int32: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension UInt32: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension Int64: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }
extension UInt64: SizeDescriptible { public var sizeDescription: SizeDescription { return .fix(CGFloat(self)) } }

// MARK: - SizeDescription

///
/// Measure a size in one dimension
public struct SizeDescription: SizeDescriptible, CustomStringConvertible, Outputing, Equatable {
    init(sizeType: SizeDescription.SizeType, fixedValue: CGFloat, ratio: CGFloat, add: CGFloat, min: CGFloat, max: CGFloat, priority: CGFloat, shrink: CGFloat, grow: CGFloat) {
        if grow > 0 {
            assert(max == .greatestFiniteMagnitude, "Grow size should not have a max value")
        }

        self.sizeType = sizeType
        self.fixedValue = fixedValue
        self.ratio = ratio
        self.add = add
        self.min = min
        self.max = max
        self.priority = priority
        self.shrink = shrink
        self.grow = grow
    }

    public typealias OutputType = SizeDescription

    public var sizeDescription: SizeDescription {
        return self
    }

    public enum SizeType {
        /// Fixed size
        case fixed
        /// Depende on residual size
        case ratio
        /// Depende on content
        case wrap
    }

    public let sizeType: SizeType

    public let fixedValue: CGFloat

    public let ratio: CGFloat
    public let add: CGFloat
    public let min: CGFloat
    public let max: CGFloat
    public let priority: CGFloat
    public let shrink: CGFloat
    public let grow: CGFloat

    public static func fix(_ value: CGFloat) -> SizeDescription {
        SizeDescription(sizeType: .fixed, fixedValue: value, ratio: 0, add: 0, min: 0, max: .greatestFiniteMagnitude, priority: 0, shrink: 0, grow: 0)
    }

    public static func ratio(_ value: CGFloat) -> SizeDescription {
        SizeDescription(sizeType: .ratio, fixedValue: 0, ratio: value, add: 0, min: 0, max: .greatestFiniteMagnitude, priority: 0, shrink: 0, grow: 0)
    }

    public static func wrap(add: CGFloat = 0, min: CGFloat = 0, max: CGFloat = .greatestFiniteMagnitude, priority: CGFloat = 0, shrink: CGFloat = 0, grow: CGFloat = 0) -> SizeDescription {
        SizeDescription(sizeType: .wrap, fixedValue: 0, ratio: 0, add: add, min: min, max: grow > 0 ? .greatestFiniteMagnitude : max, priority: priority, shrink: shrink, grow: grow)
    }

    public static var wrap: SizeDescription {
        return .wrap()
    }

    public static var fill: SizeDescription {
        return .ratio(1)
    }

    public var description: String {
        if isRatio {
            return "ratio(\(ratio))"
        } else if isWrap {
            var text = [String]()
            if add != 0 { text.append("add:\(add)") }
            if min != 0 { text.append("min:\(min)") }
            if max != .greatestFiniteMagnitude { text.append("max:\(max)") }
            if priority != 0 { text.append("priority:\(priority)") }
            if shrink != 0 { text.append("shrink:\(shrink)") }
            return "wrap(\(text.joined(separator: ", ")))"
        } else {
            return "fix(\(fixedValue))"
        }
    }
}

extension SizeDescription {
    var isWrap: Bool {
        return sizeType == .wrap
    }

    var isFixed: Bool {
        return sizeType == .fixed
    }

    var isRatio: Bool {
        return sizeType == .ratio
    }

    var isFlex: Bool {
        sizeType == .wrap && (grow > 0 || shrink > 0)
    }

    func getWrapSize(by wrappedValue: CGFloat) -> CGFloat {
        return Swift.min(Swift.max(wrappedValue + add, min), max)
    }
}

// MARK: - Size

public struct Size: Equatable, Outputing {
    public typealias OutputType = Size
    public var width: SizeDescription
    public var height: SizeDescription

    /// width / height
    public var aspectRatio: CGFloat?

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height
    }

    public init(width: SizeDescription = .fix(0), height: SizeDescription = .fix(0), aspectRatio: CGFloat? = nil) {
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
    }

    public static func fixed(_ value: CGFloat = 0) -> Size {
        Size(width: .fix(value), height: .fix(value))
    }
}

extension Size {
    func isFixed() -> Bool {
        return width.isFixed && height.isFixed
    }

    func isRatio() -> Bool {
        return width.isRatio && height.isRatio
    }

    func isWrap() -> Bool {
        return width.isWrap && height.isWrap
    }

    func getMain(direction: Direction) -> SizeDescription {
        if case .x = direction {
            return width
        }
        return height
    }

    func getCross(direction: Direction) -> SizeDescription {
        if case .x = direction {
            return height
        }
        return width
    }

    func bothNotWrap() -> Bool {
        return !maybeWrap()
    }

    func maybeWrap() -> Bool {
        return width.isWrap || height.isWrap
    }

    func maybeRatio() -> Bool {
        return width.isRatio || height.isRatio
    }

    func maybeFixed() -> Bool {
        return width.isFixed || height.isFixed
    }
}
