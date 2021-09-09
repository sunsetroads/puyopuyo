//
//  TestVC.swift
//  Puyopuyo_Example
//
//  Created by J on 2021/8/30.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Puyopuyo
import UIKit

class TestVC: BaseVC {
    let text = State("")
    override func configView() {
//        demo1().attach(vRoot)
//        demo2().attach(vRoot)
//        demo3().attach(vRoot)
//        demo4().attach(vRoot)
//        demo5().attach(vRoot)
//        demo6().attach(vRoot)
        demo7().attach(vRoot)
    }
    
    func demo7() -> UIView {
        VBox().attach {
            let state = State("sdfadsf")
            
            UITextField().attach($0)
                .size(.fill, 50)
                .onText(state)
            
            let label1Rect = State<CGRect?>(.zero)
            let label2Rect = State<CGRect?>(.zero)
            
            let container = HBox().attach($0) {
//                UIView().attach($0)
//                    .size(100, 50)
                
                UILabel().attach($0)
                    .numberOfLines(0)
                    .text(state.map { "\($0)\($0)" })
                    .width(.wrap(shrink: 1))
                    .observe(\.bounds, input: label1Rect)
                    .margin(left: 10)
                    .bind(keyPath: \.lineBreakMode, .byClipping)

                UILabel().attach($0)
                    .numberOfLines(0)
                    .text(state)
                    .width(.wrap(shrink: 1))
                    .observe(\.bounds, input: label2Rect)
                    .margin(left: 10)
                    .bind(keyPath: \.lineBreakMode, .byClipping)
                
                UILabel().attach($0)
                    .text("stay")
//                    .margin(left: 10)
                    .width(.wrap(priority: 1))
            }
//            .space(10)
//            .width(500)
//            .height(100)
            .view
            
            let original = state.map { text -> String in
                let label = UILabel()
                label.text = "\(text)\(text)"
                var size = label.sizeThatFits(.zero)
                let originWidth1 = size.width
                
                label.text = text
                size = label.sizeThatFits(.zero)
                let originWidth2 = size.width
                
                let total = "total: \(originWidth1 + originWidth2)"
                let delta = "delta: \(originWidth1 + originWidth2 - 500)"
                let origin = "width1: \(originWidth1), width2: \(originWidth2), width1 / width2 = \(originWidth1 / originWidth2)"
                
                let cal1 = originWidth1 - (originWidth1 + originWidth2 - 500) / 2
                let cal2 = originWidth2 - (originWidth1 + originWidth2 - 500) / 2
                
                let cal = "calW1: \(cal1)   calW2: \(cal2)"
                return [total, delta, origin, cal].joined(separator: "\n")
            }
            
            let containerWidth = container.py_boundsState().map { rect in
                "container width: \(rect.size.width)"
            }
            
//            let oversize = Outputs.combine(label1Rect.unwrap(or: .zero), label2Rect.unwrap(or: .zero), container.py_boundsState()).map { r1, r2, r3 in
//                "total: \(r1.width + r2.width)   delta: \(r1.width + r2.width - r3.width)"
//            }
            
            let width1 = label1Rect.unwrap(or: .zero).map { rect in
                "label1 real width: \(rect.size)"
            }
            
            let width2 = label2Rect.unwrap(or: .zero).map { rect in
                "label2 real width: \(rect.size)"
            }
            
            UILabel().attach($0)
                .numberOfLines(0)
                .size(.fill, .wrap)
                .text(Outputs.combine([original, containerWidth, width1, width2]).map { $0.joined(separator: "\n\n") })
        }
        .padding(all: 20)
        .size(.fill, .fill)
        .view
    }
    
    func demo6() -> UIView {
        HBox().attach {
            UITextField().attach($0)
                .size(100, 40)
                .onText(text)
            
//            HBox().attach($0) {
                
            UILabel().attach($0)
                .text(text)
                .margin(left: 10)
                
            UILabel().attach($0)
                .text("texttexttexttexttexttext")
                .margin(left: 10, right: 10)
                
            UIView().attach($0)
                .width(.fill)
                .margin(left: 30)
                .height(10)
                
            UILabel().attach($0)
                .text("Stay")
                .width(.wrap)
//            }
        }
//        .space(10)
//        .padding(all: 10)
        .height(.wrap)
        .width(500)
        .view
    }
    
    func demo5() -> UIView {
        HBox().attach {
            UILabel().attach($0)
                .text("f_f")
                .size(100, 100)
            
            UILabel().attach($0)
                .text("w_r")
            
            UILabel().attach($0)
                .text("w_r")
        }
        .padding(all: 10)
        .format(.round)
        .width(.fill)
        .view
    }
    
    func demo4() -> UIView {
        HBox().attach {
            UILabel().attach($0)
                .text("f_f")
                .size(100, 100)
            
            UILabel().attach($0)
                .text("w_r")
                .size(.wrap, .fill)
            
            UILabel().attach($0)
                .text("f_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskd")
                .numberOfLines(0)
                .size(.fill, .wrap)
            UILabel().attach($0)
                .text("f_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskd")
                .numberOfLines(0)
                .size(.fill, .wrap)
        }
        .padding(all: 10)
        .width(.fill)
        .view
    }
    
    func demo3() -> UIView {
        HBox().attach {
            UILabel().attach($0)
                .text("f_f")
                .size(100, 100)
            
            UILabel().attach($0)
                .text("w_r")
                .size(.wrap, .fill)
            
            UILabel().attach($0)
                .text("f_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskdf_wlkjsaldkfjlaskd")
                .numberOfLines(0)
                .size(.fill, .wrap)
        }
        .width(.fill)
        .padding(all: 10)
        .view
    }
    
    func demo2() -> UIView {
        HBox().attach {
            UILabel().attach($0)
                .numberOfLines(0)
                .text("asdkjfhalskdjflakjsdflkajsdasdkjfhalskdjflakjsdflkajsdasdkjfhalskdjflakjsdflkajsdasdkjfhalskdjflakjsdflkajsdasdkjfhalskdjflakjsdflkajsd")
            
            UILabel().attach($0)
                .text("stay")
                .size(.wrap(priority: 10), .fill)
        }
        .view
    }
    
    func demo1() -> UIView {
        let text = State("")
        return VBox().attach {
            UITextField().attach($0)
                .onText(text)
                .size(.fill, 40)
           
            HBox().attach($0) {
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(100, .wrap)
                    .text(text.map { "F_W\n\($0)" })
               
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(.wrap, 40)
                    .text(text.map { "W_F\n\($0)" })
               
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(.wrap(priority: 11), .wrap)
                    .text(text.map { "W_W\n\($0)" })
               
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(.wrap(priority: 10), .fill)
                    .text(text.map { "W_R\n\($0)" })
               
                UILabel().attach($0)
                    .numberOfLines(0)
                    .size(.fill, .wrap)
                    .text(text.map { "R_W\n\($0)" })
            }
            .size(.fill, .wrap)
            .justifyContent(.center)
        }
        .size(.fill, .wrap)
        .view
    }
    
    override func shouldRandomColor() -> Bool {
        true
    }
}
