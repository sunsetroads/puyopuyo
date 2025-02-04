//
//  BaseVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/6/30.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class BaseVC: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    var navState = State(NavigationBox.ViewState())
    var navHeight = State<SizeDescription>(.fix(44))
    let additionalSafeAreaPadding = State(UIEdgeInsets.zero)

    override func loadView() {
        super.loadView()
        NavigationBox(
            navBar: {
                NavBar(title: title ?? "\(type(of: self))").attach()
                    .height(navHeight)
                    .onEvent(to: self) { s, e in
                        if e == .tapLeading {
                            s.navigationController?.popViewController(animated: true)
                        }
                    }
                    .view
            }, body: {
                ZBox().attach {
                    let padding = Outputs.combine($0.py_safeArea(), additionalSafeAreaPadding).map { safe, add -> UIEdgeInsets in
                        UIEdgeInsets(top: safe.top + add.top, left: safe.left + add.left, bottom: safe.bottom + add.bottom, right: safe.right + add.right)
                    }
                    vRoot.attach($0)
                        .padding(padding.distinct())
                        .size(.fill, .fill)
                }
                .view
            }
        )
        .attach(view)
        .size(.fill, .fill)
        .state(navState)

        navState.value.shadowOpacity = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(BaseVC.back))
        view.backgroundColor = Theme.background
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        configView()
        if shouldRandomColor() {
            Util.randomViewColor(view: view)
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer {
            return true
        }
        return false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func shouldRandomColor() -> Bool {
        return false
    }

    lazy var vRoot = VBox()

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }

    func configView() {}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        print("\(self) deinit!!!")
    }

    override var canBecomeFirstResponder: Bool { true }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        becomeFirstResponder()
    }
}
