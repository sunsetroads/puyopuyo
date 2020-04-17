//
//  CollectionBox.swift
//  Puyopuyo
//
//  Created by Jrwong on 2019/12/23.
//

import UIKit

public protocol CollectionBoxSection: class {
    var collectionBox: CollectionBox? { get set }
    func cellIdentifier() -> String
    func cellType() -> AnyClass
    func supplementaryType(for kind: String) -> AnyClass
    func numberOfItems() -> Int
    func didSelect(item: Int)

    func cell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell
    func view(for collectionView: UICollectionView, supplementary kind: String, at indexPath: IndexPath) -> UICollectionReusableView

    func size(for collectionView: UICollectionView, layout: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize
    func insets(for collectionView: UICollectionView, layout: UICollectionViewLayout, at section: Int) -> UIEdgeInsets
    func lineSpacing(for collectionView: UICollectionView, layout: UICollectionViewLayout, at section: Int) -> CGFloat
    func interactSpacing(for collectionView: UICollectionView, layout: UICollectionViewLayout, at section: Int) -> CGFloat

    func headerSize(for collectionView: UICollectionView, layout: UICollectionViewLayout, at section: Int) -> CGSize
    func footerSize(for collectionView: UICollectionView, layout: UICollectionViewLayout, at section: Int) -> CGSize
}

public extension CollectionBoxSection {
    func supplementaryIdentifier(for kind: String) -> String {
        return cellIdentifier() + kind
    }
}

public class CollectionBox: UICollectionView,
    Stateful,
    Delegatable,
    DataSourceable,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource {
    public let viewState = State<[CollectionBoxSection]>([])

    private var delegateProxy: DelegateProxy<UICollectionViewDelegateFlowLayout>! {
        didSet {
            delegate = delegateProxy
        }
    }

    private var dataSourceProxy: DelegateProxy<UICollectionViewDataSource>! {
        didSet {
            dataSource = dataSourceProxy
        }
    }

    public private(set) var layout: UICollectionViewFlowLayout = CollectionBoxFlowLayout()

    fileprivate var sizeCache = [IndexPath: CGSize]()

    public var lineSpacing: CGFloat = 0
    public var interactSpacing: CGFloat = 0

    public init(
        layout: UICollectionViewFlowLayout = CollectionBoxFlowLayout(),
        direction: UICollectionView.ScrollDirection = .vertical,
        minimumLineSpacing: CGFloat = 0,
        minimumInteritemSpacing: CGFloat = 0,
        pinHeader: Bool = false,
        sections: [CollectionBoxSection] = []
    ) {
        layout.scrollDirection = direction
        layout.minimumLineSpacing = minimumLineSpacing
        layout.minimumInteritemSpacing = minimumInteritemSpacing
        layout.setSectionHeaderPin(pinHeader)
        super.init(frame: .zero, collectionViewLayout: layout)

        lineSpacing = minimumLineSpacing
        interactSpacing = minimumInteritemSpacing

        viewState.value = sections

        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: nil)

        backgroundColor = .clear
        delegate = delegateProxy
        dataSource = dataSourceProxy

        viewState.safeBind(to: self) { this, sections in
            sections.forEach { section in
                section.collectionBox = this
                this.register(section.cellType(), forCellWithReuseIdentifier: section.cellIdentifier())
                [UICollectionView.elementKindSectionHeader, UICollectionView.elementKindSectionFooter].forEach { type in
                    this.register(section.supplementaryType(for: type),
                                  forSupplementaryViewOfKind: type,
                                  withReuseIdentifier: section.supplementaryIdentifier(for: type))
                }
            }
            this.reloadData()
        }
    }

    public override func reloadData() {
        sizeCache.removeAll()
        super.reloadData()
    }

    public required init?(coder _: NSCoder) {
        fatalError()
    }

    // MARK: - Delegatable, DataSourceable

    public func setDelegate(_ delegate: UICollectionViewDelegateFlowLayout, retained: Bool) {
        delegateProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: RetainWrapper(value: delegate, retained: retained))
    }

    public func setDataSource(_ dataSource: UICollectionViewDataSource, retained: Bool) {
        dataSourceProxy = DelegateProxy(original: RetainWrapper(value: self, retained: false), backup: RetainWrapper(value: dataSource, retained: retained))
    }

    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource

    public func numberOfSections(in _: UICollectionView) -> Int {
        return viewState.value.count
    }

    public func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewState.value[section].numberOfItems()
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return viewState.value[indexPath.section].cell(for: collectionView, at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewState.value[indexPath.section].didSelect(item: indexPath.row)
        delegateProxy.backup?.value?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return viewState.value[indexPath.section].view(for: collectionView, supplementary: kind, at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let size = sizeCache[indexPath] {
            return size
        }
        let size = viewState.value[indexPath.section].size(for: collectionView, layout: collectionViewLayout, at: indexPath)
        sizeCache[indexPath] = size
        return size
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return viewState.value[section].headerSize(for: collectionView, layout: collectionViewLayout, at: section)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return viewState.value[section].footerSize(for: collectionView, layout: collectionViewLayout, at: section)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        viewState.value[section].insets(for: collectionView, layout: collectionViewLayout, at: section)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        viewState.value[section].lineSpacing(for: collectionView, layout: collectionViewLayout, at: section)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        viewState.value[section].interactSpacing(for: collectionView, layout: collectionViewLayout, at: section)
    }
}

public struct RecycleContext<T, View: UIView> {
    public var index: Int = 0
    public var size: CGSize = .zero
    public var data: T
    public weak var view: View?
}

public class CollectionSection<Data, Cell: UIView, CellEvent>: CollectionBoxSection {
    public weak var collectionBox: CollectionBox?

    public let dataSource = State<[Data]>([])
    public let insets = State(UIEdgeInsets.zero)

    public typealias HeaderFooterGenerator<Data, CellEvent> = (SimpleOutput<Data>, SimpleInput<CellEvent>) -> UIView?
    var headerGenerator: HeaderFooterGenerator<RecycleContext<[Data], UICollectionView>, CellEvent>
    var footerGenerator: HeaderFooterGenerator<RecycleContext<[Data], UICollectionView>, CellEvent>

    public typealias CellGenerator<Data, Cell, CellEvent> = (SimpleOutput<RecycleContext<Data, UICollectionView>>, SimpleInput<CellEvent>) -> Cell
    var cellGenerator: CellGenerator<Data, Cell, CellEvent>

    public typealias CellUpdater<Data, Cell> = (UICollectionViewCell, Cell, RecycleContext<Data, UICollectionView>) -> Void
    var cellUpdater: CellUpdater<Data, Cell>

    public typealias OnCellEvent<Event> = (Event) -> Void
    var onCellEvent: OnCellEvent<Event>

    public typealias OnBoxEvent = (EventContext) -> Void
    var onBoxEvent: OnBoxEvent
    
    public typealias ItemSize = (Data, CGSize) -> CGSize?
    var itemSizeBlock: ItemSize

    public var minLineSpacing: CGFloat?
    public var minInteractSpacing: CGFloat?

    public var identifier: String
    private var diffIdentifier: ((Data) -> String)?
    public init(identifier: String,
                dataSource: SimpleOutput<[Data]>,
                minLineSpacing: CGFloat? = nil,
                minInteractSpacing: CGFloat? = nil,
                insets: SimpleOutput<UIEdgeInsets> = UIEdgeInsets.zero.asOutput(),
                _itemSize: @escaping ItemSize = { _, _ in nil },
                _diffIdentifier: ((Data) -> String)? = nil,
                _cell: @escaping CellGenerator<Data, Cell, CellEvent>,
                _cellUpdater: @escaping CellUpdater<Data, Cell> = { _, _, _ in },
                _header: @escaping HeaderFooterGenerator<RecycleContext<[Data], UICollectionView>, CellEvent> = { _, _ in EmptyView() },
                _footer: @escaping HeaderFooterGenerator<RecycleContext<[Data], UICollectionView>, CellEvent> = { _, _ in EmptyView() },
                _event: @escaping OnCellEvent<Event> = { _ in },
                _onEvent: @escaping OnBoxEvent = { _ in }) {
        self.identifier = identifier
        cellGenerator = _cell
        cellUpdater = _cellUpdater
        onCellEvent = _event
        onBoxEvent = _onEvent
        headerGenerator = _header
        footerGenerator = _footer
        diffIdentifier = _diffIdentifier
        self.minLineSpacing = minLineSpacing
        self.minInteractSpacing = minInteractSpacing
        self.itemSizeBlock = _itemSize
        _ = dataSource.outputing { [weak self] data in
            self?.reload(with: data)
        }

        _ = insets.send(to: self.insets)
    }

    public enum Event {
        case didSelect(Int, Data)
        case headerEvent(Int, [Data], CellEvent)
        case footerEvent(Int, [Data], CellEvent)
        case itemEvent(Int, Data, CellEvent)
    }

    public struct EventContext {
        public enum Event {
            case didSelect
            case headerEvent
            case footerEvent
            case itemEvent(CellEvent)
        }

        public var event: Event
        public var recycleCtx: RecycleContext<Data, UICollectionView>
    }

    public func cellIdentifier() -> String {
        return identifier
    }

    public func cellType() -> AnyClass {
        return CollectionBoxCell<Data, CellEvent>.self
    }

    public func supplementaryType(for _: String) -> AnyClass {
        return CollectionBoxSupplementaryView<[Data], CellEvent>.self
    }

    public func numberOfItems() -> Int {
        return dataSource.value.count
    }

    public func didSelect(item: Int) {
        trigger(event: .didSelect, idx: item)
        onCellEvent(.didSelect(item, dataSource.value[item]))
    }

    public func cell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier(), for: indexPath) as? CollectionBoxCell<Data, CellEvent> else {
            fatalError()
        }
        cell.targetSize = getLayoutableContentSize(collectionView)
        let data = dataSource.value[indexPath.row]
        let ctx = RecycleContext(index: indexPath.row, size: cell.targetSize, data: data, view: collectionView)
        if cell.root == nil {
            let state = State(ctx)
            let event = SimpleIO<CellEvent>()
            let root = cellGenerator(state.asOutput(), event.asInput())
            cell.root = root
            cell.state = state
            cell.event = event
            cell.contentView.addSubview(root)
        } else {
            cell.state.value = ctx
        }
        cell.onEvent = { [weak cell, weak self] event in
            guard let self = self, let cell = cell else { return }
            let idx = cell.state.value.index
            let data = cell.state.value.data
            self.trigger(event: .itemEvent(event), idx: idx)
            self.onCellEvent(.itemEvent(idx, data, event))
        }
//        cellUpdater(cell, )
        if let view = cell.root as? Cell {
            cellUpdater(cell, view, ctx)
        }
        return cell
    }

    public func view(for collectionView: UICollectionView, supplementary kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: supplementaryIdentifier(for: kind), for: indexPath) as! CollectionBoxSupplementaryView<[Data], CellEvent>
//        view.targetSize = collectionView.bounds.size
        view.targetSize = getLayoutableContentSize(collectionView)
        if view.root == nil {
//            let state = State((indexPath.section, dataSource.value))
            let state = State(RecycleContext(index: indexPath.section, size: view.targetSize, data: dataSource.value, view: collectionView))
            let event = SimpleIO<CellEvent>()
            var root: UIView
            if kind == UICollectionView.elementKindSectionHeader {
                root = headerGenerator(state.asOutput(), event.asInput()) ?? EmptyView()
            } else {
                root = footerGenerator(state.asOutput(), event.asInput()) ?? EmptyView()
            }
            view.root = root
            view.state = state
            view.event = event
            view.addSubview(root)
        } else {
            view.state.value = RecycleContext(index: indexPath.section, size: view.targetSize, data: dataSource.value, view: collectionView)
        }
        view.onEvent = { [weak self, weak view] e in
            guard let self = self, let view = view else { return }
            let idx = view.state.value.index
            let data = view.state.value.data
            if kind == UICollectionView.elementKindSectionHeader {
                self.trigger(event: .headerEvent, idx: idx)
                self.onCellEvent(.headerEvent(idx, data, e))
            } else {
                self.trigger(event: .footerEvent, idx: idx)
                self.onCellEvent(.footerEvent(idx, data, e))
            }
        }
        return view
    }

    private let dummyItemState = State<RecycleContext<Data, UICollectionView>>.unstable()
    private lazy var dummyItem: UIView = { self.cellGenerator(self.dummyItemState.asOutput(), SimpleIO<CellEvent>().asInput()) }()

    private let dummyHeaderState = State<RecycleContext<[Data], UICollectionView>>.unstable()
    private lazy var dummyHeader: UIView = { self.headerGenerator(self.dummyHeaderState.asOutput(), SimpleIO<CellEvent>().asInput()) ?? EmptyView() }()
    private let dummyFooterState = State<RecycleContext<[Data], UICollectionView>>.unstable()
    private lazy var dummyFooter: UIView = { self.footerGenerator(self.dummyFooterState.asOutput(), SimpleIO<CellEvent>().asInput()) ?? EmptyView() }()

    func trigger(event: EventContext.Event, idx: Int) {
        guard let ctx = getEventContext(event: event, index: idx) else { return }
        onBoxEvent(ctx)
    }

    func getEventContext(event: EventContext.Event, index: Int) -> EventContext? {
        guard let tv = collectionBox else { return nil }
        return EventContext(event: event, recycleCtx: .init(index: index, size: getLayoutableContentSize(tv), data: dataSource.value[index], view: tv))
    }

    private func getLayoutableContentSize(_ cv: UICollectionView) -> CGSize {
        let width = cv.bounds.size.width - cv.contentInset.getHorzTotal() - insets.value.getHorzTotal()
        let height = cv.bounds.size.height - cv.contentInset.getVertTotal() - insets.value.getVertTotal()
        return CGSize(width: max(0, width), height: max(0, height))
    }

    public func size(for collectionView: UICollectionView, layout _: UICollectionViewLayout, at indexPath: IndexPath) -> CGSize {
        let layoutContentSize = getLayoutableContentSize(collectionView)
        if let size = itemSizeBlock(dataSource.value[indexPath.row], layoutContentSize) {
            return size
        }
        dummyItemState.value = RecycleContext(index: indexPath.row, size: getLayoutableContentSize(collectionView), data: dataSource.value[indexPath.row], view: collectionView)
        var size = dummyItem.sizeThatFits(layoutContentSize)
        size.width += dummyItem.py_measure.margin.getHorzTotal()
        size.height += dummyItem.py_measure.margin.getVertTotal()
        return CGSize(width: max(0, size.width), height: max(0, size.height))
    }

    public func insets(for _: UICollectionView, layout _: UICollectionViewLayout, at _: Int) -> UIEdgeInsets {
        insets.value
    }

    public func lineSpacing(for _: UICollectionView, layout _: UICollectionViewLayout, at _: Int) -> CGFloat {
        minLineSpacing ?? collectionBox?.lineSpacing ?? 0
    }

    public func interactSpacing(for _: UICollectionView, layout _: UICollectionViewLayout, at _: Int) -> CGFloat {
        minInteractSpacing ?? collectionBox?.interactSpacing ?? 0
    }

    public func headerSize(for collectionView: UICollectionView, layout _: UICollectionViewLayout, at section: Int) -> CGSize {
        dummyHeaderState.value = RecycleContext(index: section, size: getLayoutableContentSize(collectionView), data: dataSource.value, view: collectionView)
        return dummyHeader.sizeThatFits(getLayoutableContentSize(collectionView))
    }

    public func footerSize(for collectionView: UICollectionView, layout _: UICollectionViewLayout, at section: Int) -> CGSize {
        dummyFooterState.value = RecycleContext(index: section, size: getLayoutableContentSize(collectionView), data: dataSource.value, view: collectionView)
        return dummyFooter.sizeThatFits(getLayoutableContentSize(collectionView))
    }

    private func reload(with data: [Data]) {
        guard let box = collectionBox else {
            dataSource.value = data
            return
        }
        // 不做diff运算
        guard let diffIdentifier = self.diffIdentifier else {
            dataSource.value = data
            box.reloadData()
            return
        }
        // 需要做diff运算
        // 清空cache
        box.sizeCache.removeAll()

        let diff = Diff(src: dataSource.value, dest: data, identifier: diffIdentifier)
        diff.check()
        if diff.isDifferent(), let section = box.viewState.value.firstIndex(where: { $0 === self }) {
            dataSource.value = data
            box.performBatchUpdates({
                diff.move.forEach { c in
                    box.moveItem(at: IndexPath(row: c.from, section: section), to: IndexPath(row: c.to, section: section))
                }
                if !diff.delete.isEmpty {
                    box.deleteItems(at: diff.delete.map { IndexPath(row: $0.from, section: section) })
                }
                if !diff.insert.isEmpty {
                    box.insertItems(at: diff.insert.map { IndexPath(row: $0.to, section: section) })
                }
            }, completion: {
                // 完成编辑后，刷新不动的item
                if $0, !diff.stay.isEmpty {
                    box.reloadItems(at: diff.stay.map { IndexPath(row: $0.from, section: section) })
                }
            })
        }
    }

    public class EmptyView: UIView {
        public override func sizeThatFits(_: CGSize) -> CGSize {
            return CGSize(width: 0.1, height: 0.1)
        }
    }

    deinit {
        print("CollectionSection deinit!!!")
    }
}

private class CollectionBoxCell<D, E>: UICollectionViewCell {
    var root: UIView?
    var state: State<RecycleContext<D, UICollectionView>>!
    var event: SimpleIO<E>! {
        didSet {
            _ = event.outputing { [weak self] in
                self?.onEvent($0)
            }
        }
    }

    var onEvent: (E) -> Void = { _ in }

    var targetSize: CGSize = .zero

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
        let size = self.targetSize == .zero ? targetSize : self.targetSize
        return root?.sizeThatFits(size) ?? .zero
    }
}

private class CollectionBoxSupplementaryView<D, E>: UICollectionReusableView {
    var root: UIView?
    var state: State<RecycleContext<D, UICollectionView>>!
    var event: SimpleIO<E>! {
        didSet {
            _ = event.outputing { [weak self] in
                self?.onEvent($0)
            }
        }
    }

    var onEvent: (E) -> Void = { _ in }

    var targetSize: CGSize = .zero

    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority _: UILayoutPriority, verticalFittingPriority _: UILayoutPriority) -> CGSize {
        let size = self.targetSize == .zero ? targetSize : self.targetSize
        return root?.sizeThatFits(size) ?? .zero
    }
}

extension PYProxyChain: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let target = target(with: #selector(UICollectionViewDataSource.collectionView(_:numberOfItemsInSection:))) as? UICollectionViewDataSource else {
            return 0
        }
        return target.collectionView(collectionView, numberOfItemsInSection: section)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let target = target(with: #selector(UICollectionViewDataSource.collectionView(_:cellForItemAt:))) as? UICollectionViewDataSource else {
            return UICollectionViewCell()
        }
        return target.collectionView(collectionView, cellForItemAt: indexPath)
    }
}

public extension Puyo where T: CollectionBox {
    @discardableResult
    func reload<O: Outputing>(_ when: O) -> Self where O.OutputType: Any {
        when.safeBind(to: view) { v, _ in
            v.reloadData()
        }
        return self
    }
}
