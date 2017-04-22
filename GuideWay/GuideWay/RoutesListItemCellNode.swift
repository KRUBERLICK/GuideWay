//
//  RoutesListItemCellNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/20/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

class RoutesListItemCellNode: ASCellNode {
    var route: Route

    lazy var titleTextNode = ASTextNode()

    lazy var originDestinationNode: RouteDetailsOriginDestinationRouteCellNode = {
        return RouteDetailsOriginDestinationRouteCellNode(route: self.route)
    }()

    lazy var backgroundImageNode: ASImageNode = {
        let node = ASImageNode()
        let image = UIImage.as_resizableRoundedImage(
            withCornerRadius: 5,
            cornerColor: .clear,
            fill: UIColor(hexString: "6281A2")
        )

        node.image = image
        return node
    }()

    var onTap: ((Route) -> ())?
    var databaseManager: DatabaseManager
    var disposeBag = DisposeBag()

    init(route: Route, databaseManager: DatabaseManager) {
        self.route = route
        self.databaseManager = databaseManager
        super.init()
        automaticallyManagesSubnodes = true
        backgroundColor = .clear
        clipsToBounds = true
        bindData()
    }

    func bindData() {
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.systemFont(ofSize: 30)
        ]

        titleTextNode.attributedText = NSAttributedString(
            string: route.title
                ?? NSLocalizedString("route_details.route_title", comment: ""),
            attributes: textAttribs
        )
    }

    override func didLoad() {
        super.didLoad()
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, 
                action: #selector(RoutesListItemCellNode.tapHandler)
            )
        )
        databaseManager.listenForRouteUpdates(routeId: route.id!)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] route in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.route = route
                strongSelf.bindData()
            })
            .addDisposableTo(disposeBag)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let centeredTitleStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 0, 
            justifyContent: .center, 
            alignItems: .center, 
            children: [titleTextNode]
        )
        let titleInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), 
            child: centeredTitleStack
        )
        let titleAndOriginDestinationStack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 8, 
            justifyContent: .center, 
            alignItems: .stretch, 
            children: [titleInsets, originDestinationNode]
        )
        let finalInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 14, left: 0, bottom: 24, right: 0), 
            child: titleAndOriginDestinationStack
        )
        let backgroundImage = ASBackgroundLayoutSpec(
            child: finalInsets, 
            background: backgroundImageNode
        )

        return backgroundImage
    }

    func tapHandler() {
        onTap?(route)
    }
}
