//
//  TestVC.swift
//  Puyopuyo_Example
//
//  Created by Jrwong on 2019/8/18.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Puyopuyo
import TangramKit

class TestVC: BaseVC {
    override func viewDidLoad() {
        super.viewDidLoad()
//        test1()
//        tk_flowTest()
        py_flow()
        randomViewColor(view: view)
    }
    
    private func py_flow() {
        vRoot.attach() {
            VFlow(count: 3).attach($0) {
                for idx in 0..<10 {
                    Label("\(idx + 1)").attach($0)
                        .width(60)
                        .heightOnSelf({ .fix($0.width) })
                }
                
                }
                .size(.fill, .fill)
                .margin(all: 10)
                .attach() {
                    $0.layout.hSpace = 10
                    $0.layout.vSpace = 20
//                    $0.layout.vFormation = .sides
                    $0.layout.padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                }
        }
    }
    
    private func test1() {
        vRoot.attach()
            .space(10)
            .attach() {
                
            HBox().attach($0)
                .size(.fill, 100)
                .margin(all: 10)
                .padding(all: 10)
                .attach() {
                    
                Label("正").attach($0)
                    .height(.fill)
                    .widthOnSelf({ .fix($0.height) })
                    .widthOnSelf({ .fix($0.height * 0.5) })
                
                Label("fill").attach($0)
                    .size(.fill, .fill)
                
                let v = $0
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.vRoot.animate(0.2, block: {
                        v.attach().height(200)
                    })
                })
            }
            
            
            let v = ZBox().attach($0) {
                
                let total = 10
                for idx in 0..<total {
                    UIView().attach($0)
                        .width(on: $0, { .fix($0.width * (1 - CGFloat(idx) / CGFloat(total))) })
                        .height(on: $0, { .fix($0.height * (1 - CGFloat(idx) / CGFloat(total))) })
                }
                
                
            }
            .width(.fill)
            .heightOnSelf({ .fix($0.width * 0.5) })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                v.view.animate(0.25, block: {
                    v.heightOnSelf({ .fix($0.width) })
                })
            })
            
            
            
        }
    }
    
    private func tk_flowTest() {
//        TGFlowLayout(.vert, arrangedCount: 3).attach() { x in
        TGFloatLayout().attach() { x in
        
            let labels = Array(repeating: 1, count: 10).map({ (idx) in
                return Label("\(idx)")
            })
            
            for (idx, label) in labels.enumerated() {
                label.attach(x)
                    .text("\(idx)")
                    .tg_size(50 + idx * 3, 50 + idx * 3 + 1)
                
//                if idx % 3 == 2 && idx != 2 {
                if idx == 2 {
                    label.tg_reverseFloat = true
//                    label.attach().tg_size(.fill, 50)
                }
            }
            
            }
            .size(.fill, .fill)
            .tg_gravity(TGGravity.horz.right)
            .tg_size(.fill, .fill)
            .activated(_S(false))
            .attach(vRoot)
    }
}
