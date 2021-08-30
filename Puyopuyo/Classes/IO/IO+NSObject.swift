//
//  IO+NSObject.swift
//  Puyopuyo
//
//  Created by J on 2021/8/24.
//

import Foundation

extension NSObject: DisposableBag {
    public func py_observing<Value: Equatable>(for keyPath: String, id: String = UUID().description) -> Outputs<Value?> {
        return Outputs<Value?> { i -> Disposer in
            var lastValue: Value?
            let observer = _Observer<Value>(key: keyPath) { rect in
                guard rect != lastValue else { return }
                lastValue = rect
                i.input(value: rect)
            }
            let disposer = Disposers.create { [unowned(unsafe) self] in
                self.removeObserver(observer, forKeyPath: keyPath)
            }
            self.addObserver(observer, forKeyPath: keyPath, options: [.new, .initial], context: nil)
            self.addDisposer(disposer, for: id)
            return disposer
        }
        .distinct()
    }

    private func py_identifier() -> String {
        return "\(Unmanaged.passRetained(self).toOpaque())"
    }

    public func addDisposer(_ Disposable: Disposer, for key: String) {
        py_disposerContainer.setDisposable(Disposable, for: key)
    }

    @discardableResult
    private func py_removeDisposable(for key: String) -> Disposer? {
        return py_disposerContainer.removeDisposable(for: key)
    }

    private static var puyopuyo_DisposableContainerKey = "puyoDisposable"
    private var py_disposerContainer: DisposableContainer {
        var container = objc_getAssociatedObject(self, &NSObject.puyopuyo_DisposableContainerKey)
        if container == nil {
            container = DisposableContainer()
            objc_setAssociatedObject(self, &NSObject.puyopuyo_DisposableContainerKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return container as! DisposableContainer
    }

    private class DisposableContainer: NSObject {
        private var disposers = [String: Disposer]()

        func setDisposable(_ Disposable: Disposer, for key: String) {
            let old = disposers[key]
            old?.dispose()
            disposers[key] = Disposable
        }

        func removeDisposable(for key: String) -> Disposer? {
            return disposers.removeValue(forKey: key)
        }

        deinit {
            disposers.forEach { _, Disposable in
                Disposable.dispose()
            }
        }
    }
}

private class _Observer<Value>: NSObject {
    var key: String = ""
    var change: (Value?) -> Void = { _ in }
    init(key: String, change: @escaping (Value?) -> Void) {
        super.init()
        self.key = key
        self.change = change
    }

    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        if keyPath == key {
            if let change = change {
                self.change(change[.newKey] as? Value)
            } else {
                self.change(nil)
            }
        }
    }
}
