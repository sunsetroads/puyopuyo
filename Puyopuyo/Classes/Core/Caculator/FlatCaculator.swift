//
//  LineCaculator.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/6/29.
//

import Foundation

class FlatCaculator {
    
    let regulator: FlatRegulator
    let parent: Measure
    init(_ regulator: FlatRegulator, parent: Measure) {
        self.regulator = regulator
        self.parent = parent
    }
    
    lazy var regFixedSize = CalFixedSize(cgSize: self.regulator.py_size, direction: regulator.direction)
    lazy var regCalPadding = CalEdges(insets: regulator.padding, direction: regulator.direction)
    lazy var regCalSize = CalSize(size: regulator.size, direction: regulator.direction)
    lazy var totalFixedMain = regCalPadding.start + regCalPadding.end
    var maxCross: CGFloat = 0

    /// 主轴比例子项目
    var ratioMainMeasures = [Measure]()
    /// 主轴比例分母
    var totalMainRatio: CGFloat = 0
    /// 需要计算的子节点
    var caculateChildren = [Measure]()
    
    /// 是否可用format，主轴为包裹，或者ratioMeasures.count > 0 则不能使用
    var formattable: Bool = true
    
    /// 计算本身布局属性，可能返回的size 为 .fixed, .ratio, 不可能返回wrap
    func caculate() -> Size {
        /// 在此需要假定layout的尺寸已经计算好了
        
        // 1、 第一次循环，获取需要计算的子节点
        var filteredChildren = [Measure]()
        regulator.enumerateChild { (idx, m) in
            // 过滤非激活节点
            guard m.activated else { return }
            filteredChildren.append(m)
            // 1.1、需要处理formattable
            if formattable
                && (m.size.getCalSize(by: regulator.direction).main.isRatio || regCalSize.main.isWrap) {
                formattable = false
                if regulator.format != .leading {
                    print("Constraint error!!! Regulator's Format.\(regulator.format) reset to .leading")
                    regulator.format = .leading
                }
            }
        }
        
        // 1.1 扩充容器，提前确定容量，避免重复开辟空间
        if formattable {
            switch regulator.format {
            case .center: caculateChildren.reserveCapacity(filteredChildren.count + 2)
            case .avg: caculateChildren.reserveCapacity(filteredChildren.count * 2 + 1)
            case .sides: caculateChildren.reserveCapacity(filteredChildren.count * 2 - 1)
            default: caculateChildren.reserveCapacity(filteredChildren.count)
            }
        } else {
            caculateChildren.reserveCapacity(filteredChildren.count)
        }
        
        // 2、 第二次循环，开始计算普通节点尺寸
        // 2.1、同时需要把format一并计算，减少循环，format需要添加的位置尾，一前一后，和中间插缝
        let originChildrenTotal = filteredChildren.count
        
        // 2.2、插入首format 首center, avg
        if (formattable) && (regulator.format == .center || regulator.format == .avg) {
            let holder = getPlaceholder()
            var edges = holder.margin.getCalEdges(by: regulator.direction)
            edges.start = -regulator.space
            holder.margin = edges.getInsets()
            appendAndRegulateChild(holder)
        }
        // 2.3、计算中间节点和插入format节点
        filteredChildren.enumerated().forEach { (idx, m) in
            
            // 当前节点
            appendAndRegulateChild(m)
            
            // format 中side,avg, 子节点必须 2 个以上才能使用
            if (formattable && idx != originChildrenTotal - 1) && (regulator.format == .sides || regulator.format == .avg) {
                let holder = getPlaceholder()
                var edges = holder.margin.getCalEdges(by: regulator.direction)
                edges.start = -regulator.space
                holder.margin = edges.getInsets()
                appendAndRegulateChild(holder)
            }
            
        }
        // 2.4 插入尾format 尾center,avg
        if (formattable) && (regulator.format == .center || regulator.format == .avg) {
            let holder = getPlaceholder()
            var edges = holder.margin.getCalEdges(by: regulator.direction)
            edges.start = -regulator.space
            holder.margin = edges.getInsets()
            appendAndRegulateChild(holder)
        }
        
        // 3、累加space到totalFixedMain
        totalFixedMain += max(0, (CGFloat(caculateChildren.count - 1) * regulator.space))
        
        // 4、第三次循环，计算主轴上的比例节点
        ratioMainMeasures.forEach { (measure) in
            let subSize = measure.caculate(byParent: regulator)
            let calSize = CalSize(size: subSize, direction: regulator.direction)
            let calMargin = CalEdges(insets: measure.margin, direction: regulator.direction)
            // cross
            var subCrossSize = calSize.cross
            
            if subCrossSize.isRatio {
                let ratio = subCrossSize.ratio
                subCrossSize = .fix(max(0, (regFixedSize.cross - (regCalPadding.crossFixed + calMargin.crossFixed)) * ratio))
            }
            // main
            let subMainSize = SizeDescription.fix(max(0, (calSize.main.ratio / totalMainRatio) * (regFixedSize.main - totalFixedMain)))
            measure.py_size = CalFixedSize(main: subMainSize.fixedValue, cross: subCrossSize.fixedValue, direction: regulator.direction).getSize()
            maxCross = max(subCrossSize.fixedValue + calMargin.crossFixed, maxCross)
        }
        
        // 5、第四次循环，计算子节点center，若format == .trailing, 则可能出现第六次循环
        let lastEnd = caculateCenter(measures: caculateChildren)
        
        // 计算自身大小
        var main = regulator.size.getMain(parent: parent.direction)
        if main.isWrap {
            if parent.direction == regulator.direction {
                main = .fix(main.getWrapSize(by: lastEnd + regCalPadding.end))
            } else {
                main = .fix(main.getWrapSize(by: maxCross + regCalPadding.crossFixed))
            }
        }
        var cross = regulator.size.getCross(parent: parent.direction)
        if cross.isWrap {
            if parent.direction == regulator.direction {
                cross = .fix(cross.getWrapSize(by: maxCross + regCalPadding.crossFixed))
            } else {
                cross = .fix(cross.getWrapSize(by: lastEnd + regCalPadding.end))
            }
        }
        
        return CalSize(main: main, cross: cross, direction: parent.direction).getSize()
        
    }
    
    private func getPlaceholder() -> Measure {
        let m = Measure()
        m.size = CalSize(main: .fill, cross: .fix(0), direction: regulator.direction).getSize()
        return m
    }
    
    private func appendAndRegulateChild(_ measure: Measure) {
        caculateChildren.append(measure)
        // 计算size的具体值
        let subSize = measure.caculate(byParent: regulator)
        if subSize.width.isWrap || subSize.height.isWrap {
            fatalError("计算后的尺寸不能是包裹")
        }
        
        /// 子margin
        let subCalMargin = CalEdges(insets: measure.margin, direction: regulator.direction)
        // 累计margin
        totalFixedMain += (subCalMargin.mainFixed)
        // main
        let subCalSize = CalSize(size: subSize, direction: regulator.direction)
        
        if subCalSize.main.isRatio {
            // 需要保存起来，最后计算
            ratioMainMeasures.append(measure)
            totalMainRatio += subCalSize.main.ratio
        } else {
            // cross
            var subCrossSize = subCalSize.cross
            if subCalSize.cross.isRatio {
                let ratio = subCalSize.cross.ratio
                subCrossSize = .fix((regFixedSize.cross - (regCalPadding.crossFixed + subCalMargin.crossFixed)) * ratio)
            }
            // 设置具体size
            measure.py_size = CalFixedSize(main: subCalSize.main.fixedValue, cross: subCrossSize.fixedValue, direction: regulator.direction).getSize()
            // 记录最大cross
            maxCross = max(subCrossSize.fixedValue + subCalMargin.crossFixed, maxCross)
            // 累计main长度
            totalFixedMain += subCalSize.main.fixedValue
        }
    }
    
    /// 这里为measures的大小都计算好，需要计算每个节点的center
    ///
    /// - Parameters:
    ///   - measures: 已经计算好大小的节点
    /// - Returns: 返回最后节点的end(包括最后一个节点的margin.end)
    private func caculateCenter(measures: [Measure]) -> CGFloat {
        
        var lastEnd: CGFloat = regCalPadding.start
        
        var children = measures
        if regulator.reverse {
            children.reverse()
        }
        
        for (idx, measure) in children.enumerated() {
            lastEnd = _caculateCenter(measure: measure, at: idx, from: lastEnd)
        }
        
        if regulator.format == .trailing {
            // 如果格式化为靠后，则需要最后重排一遍
            // 计算最后一个需要移动的距离
            let delta = regFixedSize.main - regCalPadding.end - lastEnd
            if regulator.direction == .x {
                children.forEach({ $0.py_center.x += delta })
            } else {
                children.forEach({ $0.py_center.y += delta })
            }
        }
        
        return lastEnd
    }
    
    private func _caculateCenter(measure: Measure, at index: Int, from end: CGFloat) -> CGFloat {
        
        let calMargin = CalEdges(insets: measure.margin, direction: regulator.direction)
        let calSize = CalFixedSize(cgSize: measure.py_size, direction: regulator.direction)
        let space = (index == 0) ? 0 : regulator.space
        
        // main = end + 间距 + 自身顶部margin + 自身主轴一半
        let main = end + space + calMargin.start + calSize.main / 2
        
        // cross
        let cross: CGFloat
        let aligment = measure.aligment.contains(.none) ? regulator.justifyContent : measure.aligment
        if aligment.isCenter(for: regulator.direction) {
            cross = regFixedSize.cross / 2
            
        } else if aligment.isBackward(for: regulator.direction) {
            cross = regFixedSize.cross - (regCalPadding.backward + calMargin.backward + calSize.cross / 2)
        } else {
            // 若无设置，则默认forward
            cross = calSize.cross / 2 + regCalPadding.forward + calMargin.forward
        }
        
        let center = CalCenter(main: main, cross: cross, direction: regulator.direction).getPoint()
        measure.py_center = center
        
        return main + calSize.main / 2 + calMargin.end
    }
    
}
