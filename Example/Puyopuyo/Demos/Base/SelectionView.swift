//
//  SelectionView.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/12/6.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

struct Selector<T> {
    var desc: String
    var value: T
}

class SelectionView<T: Equatable>: VFlow, Stateful, Eventable {
    private var selection = [Selector<T>]()

    var state = State<T?>(nil)
    var emitter = SimpleIO<T>()

    init(_ selection: [Selector<T>], selected: T? = nil) {
        self.selection = selection
        state.value = selected
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func buildBody() {
        attach { v in
            selection.enumerated().forEach { [weak self] arg in
                guard let self = self else { return }
                let (_, x) = arg

                UIButton(type: .roundedRect).attach(v)
                    .onTap(to: self) { this, _ in
                        this.emitter.input(value: x.value)
                        this.state.value = x.value
                    }
                    .viewUpdate(on: binder) { btn, e in
                        if e == x.value {
                            btn.backgroundColor = Theme.accentColor
                            btn.isSelected = true
                        } else {
                            btn.backgroundColor = .clear
                            btn.isSelected = false
                        }
                    }
                    .styles([TapTransformStyle(), TapRippleStyle()])
                    .borderWidth(Util.pixel(1))
                    .borderColor(Theme.accentColor)
                    .cornerRadius(4)
                    .textColor(UIColor.black, state: .normal)
                    .textColor(Theme.antiAccentColor, state: .selected)
                    .width(.wrap(add: 6))
                    .text(x.desc, state: .normal)
            }
        }
        .arrangeCount(0)
        .padding(all: 10)
        .space(5)
        .animator(Animators.default)
    }
}

class PlainSelectionView<T: Equatable>: ZBox, Eventable, Stateful {
    private var selection = [Selector<T>]()
    var state = State<T?>(nil)
    var emitter = SimpleIO<T>()

    init(_ selection: [Selector<T>], selected: T? = nil) {
        self.selection = selection
        state.value = selected
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func buildBody() {
        ScrollingBox<HBox>(
            flat: {
                HBox().attach()
                    .space(4)
                    .justifyContent(.center)
                    .view
            },
            direction: .x,
            builder: { v in
                selection.forEach { [weak self] x in
                    guard let self = self else { return }
//                    v.subviews.forEach({ $0.removeFromSuperview() })
                    UIButton().attach(v)
                        .onTap(to: self) { this, _ in
                            this.emitter.input(value: x.value)
                            this.state.value = x.value
                        }
                        .backgroundColor(state.asOutput().map { e -> UIColor in
                            if e == x.value {
                                return Theme.accentColor
                            }
                            return .clear
                        })
                        .styles([
                            TapTransformStyle(),
                        ])
                        .borderWidth(Util.pixel(1))
                        .borderColor(Theme.accentColor)
                        .cornerRadius(4)
                        .textColor(UIColor.black, state: .normal)
                        .width(.wrap(add: 6))
                        .text(x.desc, state: .normal)
                }
            }
        )
        .attach(self)
        .size(.fill, .fill)
    }
}
