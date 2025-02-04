//
//  OutputModifier.swift
//  Puyopuyo
//
//  Created by J on 2021/8/30.
//

import Foundation

public protocol OutputingModifier {}

public extension OutputingModifier where Self: Outputing {
    func concat<T>(_ action: @escaping (OutputType, Inputs<T>) -> Void) -> Outputs<T> {
        Outputs<T>({ i in
            self.outputing {
                action($0, i)
            }
        })
    }

    func some() -> Outputs<OutputType?> {
        asOutput().map { $0 }
    }

    func map<R>(_ block: @escaping (OutputType) -> R) -> Outputs<R> {
        concat { $1.input(value: block($0)) }
    }

    func map<R>(_ keyPath: KeyPath<OutputType, R>) -> Outputs<R> {
        concat { $1.input(value: $0[keyPath: keyPath]) }
    }

    func filter(_ filter: @escaping (OutputType) -> Bool) -> Outputs<OutputType> {
        concat { v, i in
            if filter(v) { i.input(value: v) }
        }
    }

    func ignore(_ condition: @escaping (OutputType, OutputType) -> Bool) -> Outputs<OutputType> {
        Outputs { i in
            var last: OutputType?
            return self.outputing { v in
                if let lastValue = last {
                    if !condition(lastValue, v) {
                        i.input(value: v)
                    }
                } else {
                    i.input(value: v)
                }
                last = v
            }
        }
    }

    func take(_ count: Int) -> Outputs<OutputType> {
        Outputs { i in
            var times: Int = 0
            return self.outputing { v in
                guard times <= count else { return }
                i.input(value: v)
                times += 1
            }
        }
    }

    func skip(_ count: Int) -> Outputs<OutputType> {
        Outputs { i in
            var times: Int = 0
            return self.outputing { v in
                guard times > count else { return }
                i.input(value: v)
                times += 1
            }
        }
    }

    func then<R>(_ then: @escaping (OutputType) -> Outputs<R>) -> Outputs<R> {
        concat {
            _ = then($0).send(to: $1)
        }
    }

    func combine<O: Outputing>(_ other: O) -> Outputs<(OutputType, O.OutputType)> {
        Outputs.combine(self, other)
    }

    func dispatchMain() -> Outputs<OutputType> {
        concat { o, i in
            DispatchQueue.main.async {
                i.input(value: o)
            }
        }
    }

    func debounce(interval: TimeInterval = 0) -> Outputs<OutputType> {
        Outputs { i in
            var indicator: UInt64 = 0
            return self.outputing { o in
                indicator += 1
                let current = indicator
                DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                    if current == indicator {
                        i.input(value: o)
                    }
                }
            }
        }
    }

    var binder: OutputBinder<OutputType> {
        OutputBinder(output: asOutput())
    }
}

public extension OutputingModifier where Self: Outputing, Self.OutputType: OptionalableValueType {
    func map<R>(_ keyPath: KeyPath<OutputType.Wrap, R>, _ default: R) -> Outputs<R?> {
        concat {
            if let v = $0.optionalValue {
                $1.input(value: v[keyPath: keyPath])
            } else {
                $1.input(value: `default`)
            }
        }
    }

    func unwrap(or: OutputType.Wrap) -> Outputs<OutputType.Wrap> {
        concat { v, i in
            if let v = v.optionalValue {
                i.input(value: v)
            } else {
                i.input(value: or)
            }
        }
    }
}

public extension OutputingModifier where Self: Outputing, Self.OutputType: Equatable {
    func distinct() -> Outputs<OutputType> {
        ignore { $0 == $1 }
    }
}
