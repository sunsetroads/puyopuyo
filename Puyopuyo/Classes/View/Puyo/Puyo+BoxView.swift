//
//  Puyo+ListBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/7/2.
//

import Foundation

// MARK: - BoxView

public extension Puyo where T: Boxable & UIView {
    @discardableResult
    func padding(all: CGFloatable? = nil,
                 horz: CGFloatable? = nil,
                 vert: CGFloatable? = nil,
                 top: CGFloatable? = nil,
                 left: CGFloatable? = nil,
                 bottom: CGFloatable? = nil,
                 right: CGFloatable? = nil) -> Self
    {
        PuyoHelper.padding(for: view, all: all?.cgFloatValue, horz: horz?.cgFloatValue, vert: vert?.cgFloatValue, top: top?.cgFloatValue, left: left?.cgFloatValue, bottom: bottom?.cgFloatValue, right: right?.cgFloatValue)
        return self
    }

    @discardableResult
    func padding<S: Outputing>(all: S? = nil, horz: S? = nil, vert: S? = nil, top: S? = nil, left: S? = nil, bottom: S? = nil, right: S? = nil) -> Self where S.OutputType: CGFloatable {
        if let s = all {
            doOn(s) { PuyoHelper.padding(for: $0, all: $1.cgFloatValue) }
        }
        if let s = top {
            doOn(s) { PuyoHelper.padding(for: $0, top: $1.cgFloatValue) }
        }
        if let s = horz {
            doOn(s) { PuyoHelper.padding(for: $0, horz: $1.cgFloatValue) }
        }
        if let s = vert {
            doOn(s) { PuyoHelper.padding(for: $0, vert: $1.cgFloatValue) }
        }
        if let s = left {
            doOn(s) { PuyoHelper.padding(for: $0, left: $1.cgFloatValue) }
        }
        if let s = bottom {
            doOn(s) { PuyoHelper.padding(for: $0, bottom: $1.cgFloatValue) }
        }
        if let s = right {
            doOn(s) { PuyoHelper.padding(for: $0, right: $1.cgFloatValue) }
        }
        return self
    }

    @discardableResult
    func padding<O: Outputing>(_ padding: O) -> Self where O.OutputType == UIEdgeInsets {
        set(\T.regulator.padding, padding)
    }

    @discardableResult
    func justifyContent(_ alignment: Alignment) -> Self {
        set(\T.regulator.justifyContent, alignment)
    }

    @discardableResult
    func justifyContent<O: Outputing>(_ alignment: O) -> Self where O.OutputType == Alignment {
        set(\T.regulator.justifyContent, alignment)
    }

    @discardableResult
    func autoJudgeScroll(_ judge: Bool) -> Self {
        set(\T.control.isScrollViewControl, judge)
    }

    @discardableResult
    func isCenterControl(_ control: Bool) -> Self {
        set(\T.control.isCenterControl, control)
    }

    @discardableResult
    func isSizeControl(_ control: Bool) -> Self {
        set(\T.control.isSizeControl, control)
    }

    @discardableResult
    func borders(_ options: [BorderOptions]) -> Self {
        set(\T.control.borders, Borders.all(Border(options: options)))
    }

    @discardableResult
    func topBorder(_ options: [BorderOptions]) -> Self {
        set(\T.control.borders.top, Border(options: options))
    }

    @discardableResult
    func leftBorder(_ options: [BorderOptions]) -> Self {
        set(\T.control.borders.left, Border(options: options))
    }

    @discardableResult
    func bottomBorder(_ options: [BorderOptions]) -> Self {
        set(\T.control.borders.bottom, Border(options: options))
    }

    @discardableResult
    func rightBorder(_ options: [BorderOptions]) -> Self {
        set(\T.control.borders.right, Border(options: options))
    }
}

// MARK: - Eventable

/// When `T` is Eventable, call when emitter emit some events
public extension Puyo where T: Eventable {
    @discardableResult
    func onEvent<I: Inputing>(_ input: I) -> Self where I.InputType == T.EmitterType.OutputType {
        let disposer = view.emitter.send(to: input)
        if let v = view as? DisposableBag {
            disposer.dispose(by: v)
        }
        return self
    }

    @discardableResult
    func onEvent(_ event: @escaping (T.EmitterType.OutputType) -> Void) -> Self {
        onEvent(Inputs(event))
    }

    @discardableResult
    func onEvent<O: AnyObject>(to: O?, _ event: @escaping (O, T.EmitterType.OutputType) -> Void) -> Self {
        onEvent(Inputs { [weak to] v in
            if let to = to {
                event(to, v)
            }
        })
    }
}

public extension Puyo where T: Eventable, T.EmitterType.OutputType: Equatable {
    @discardableResult
    func onEvent(_ eventType: T.EmitterType.OutputType, _ event: @escaping () -> Void) -> Self {
        onEvent(Inputs {
            if eventType == $0 {
                event()
            }
        })
    }
}

// MARK: - Stateful

public extension Puyo where T: Stateful & DisposableBag {
    @discardableResult
    func state<O: Outputing>(_ output: O) -> Self where O.OutputType == T.StateType.OutputType {
        doOn(output) { $0.state.input(value: $1) }
    }
}

// MARK: - Delegatable & DataSourceable

public extension Puyo where T: Delegatable {
    @discardableResult
    func setDelegate(_ delegate: T.DelegateType, retained: Bool = false) -> Self {
        view.setDelegate(delegate, retained: retained)
        return self
    }
}

public extension Puyo where T: DataSourceable {
    @discardableResult
    func setDataSource(_ dataSource: T.DataSourceType, retained: Bool = false) -> Self {
        view.setDataSource(dataSource, retained: retained)
        return self
    }
}
