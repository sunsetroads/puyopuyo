//
//  RecycleBoxPropertiesVC.swift
//  Puyopuyo_Example
//
//  Created by 王俊仁 on 2020/5/12.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Puyopuyo

class RecycleBoxPropertiesVC: BaseVC {
    let sections = State<[IRecycleSection]>([])

    override func configView() {
        vRoot.attach {
            RecycleBox(
                pinHeader: true,
                estimatedSize: CGSize(width: 50, height: 50),
                sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                diff: true,
                sections: sections.asOutput()
            )
            .attach($0)
            .size(.fill, .fill)
        }

//        reloadWithMultipleSectionAnimationSeparated()
//        reloadMultipleSectionToOne()
//        randomShuffleAnimation()
        
        colorBlocks()
    }

    func colorBlocks() {
        let color = Util.randomColor()
        sections.value = [
            DataRecycleSection(
                lineSpacing: 10,
                itemSpacing: 10,
                items: (0..<6).map { $0 }.asOutput(),
                cell: { o, _ in
                    let w = o.layoutableSize.width.map {
                        ($0 - 3 * 10) / 3
                    }
                    return HBox().attach {
                        Label.demo("").attach($0)
                            .text(o.data.description)
                            .size(w, w)
                            .backgroundColor(color)
                    }
                    .view
                }
            )
        ]
    }

    func randomShuffleAnimation() {
        let names = State(Names().random(10))

        sections.value = [
            DataRecycleSection(
                items: names.asOutput(),
                differ: { $0 },
                cell: { o, _ in
                    HorzFillCell().attach()
                        .viewState(o.data)
                        .view
                },
                header: { _, _ in
                    HBox().attach {
                        UIButton().attach($0)
                            .image(UIImage(systemName: "play.fill"))
                            .bind(event: .touchUpInside, input: Inputs { _ in
                                names.value.shuffle()
                            })
                    }
                    .padding(all: 10)
                    .view
                }
            )
        ]
    }

    func reloadMultipleSectionToOne() {
        let dataSource = State([
            (0..<5).map { $0 },
            (5..<10).map { $0 },
            (6..<20).map { $0 }
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dataSource.value = [(0..<20).reversed().map { $0 }]
        }

        dataSource.map { sections -> [IRecycleSection] in
            sections.map { rows in
                BasicRecycleSection(
                    data: (),
                    items: rows.map { row in
                        BasicRecycleItem(
                            data: row,
                            differ: { $0.description },
                            cell: { o, _ in
                                SquareCell().attach()
                                    .viewState(o.data.description)
                                    .view
                            }
                        )

                    }.asOutput()
                )
            }
        }
        .send(to: sections)
        .dispose(by: self)
    }

    func reloadWithMultipleSectionAnimationSeparated() {
        let section1 = State((0..<5).map { $0 })
        let section2 = State((6..<10).map { $0 })

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            section1.value = (4..<10).map { $0 }
            section2.value = (4..<20).map { $0 }
        }

        sections.value = [
            DataRecycleSection(
                items: section1.asOutput(),
                differ: { $0.description },
                cell: { o, _ in
                    SquareCell().attach()
                        .viewState(o.data.description)
                        .view
                }
            ),
            DataRecycleSection(
                items: section2.asOutput(),
                differ: { $0.description },
                cell: { o, _ in
                    SquareCell().attach()
                        .viewState(o.data.description)
                        .view
                }
            )
        ]
    }
}

private class SquareCell: HBox, Stateful {
    var viewState = State<String>.unstable()

    override func buildBody() {
        attach {
            Label.demo("").attach($0)
                .text(binder.description)
                .size(.wrap(min: 50), .wrap(min: 50))
        }
        .padding(all: 10)
    }
}

private class HorzFillCell: HBox, Stateful {
    var viewState = State<String>.unstable()

    override func buildBody() {
        attach {
            Label.demo("").attach($0)
                .size(.fill, .wrap(min: 50))
                .text(binder)
        }
        .width(.fill)
        .padding(all: 10)
    }
}
