//
//  MapViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/14/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

class RouteMapViewController: ASViewController<ASDisplayNode> {
    enum Mode {
        case practice
        case testing
    }

    let presentationManager: PresentationManager
    let routeMapDisplayNode: RouteMapDisplayNode
    var route: Route
    let mode: Mode
    var currentSegment = 0
    var wrongAnswersIndexes = [Int]()

    var totalSegmentsCount: Int {
        return route.directions?.legs.first?.steps.count ?? 0
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    init(presentationManager: PresentationManager,
         route: Route,
         mode: Mode) {
        self.presentationManager = presentationManager
        self.route = route
        self.mode = mode
        routeMapDisplayNode = self.presentationManager
            .getRouteMapDisplayNode(with: self.route, mode: self.mode)

        let firstNode = ASDisplayNode()

        firstNode.backgroundColor = UIColor(hexString: "4A90E2")

        let mainNode = ASDisplayNode()

        mainNode.automaticallyManagesSubnodes = true
        super.init(node: mainNode)
        mainNode.layoutSpecBlock = { node, constrainedSize in
            firstNode.style.flexBasis = ASDimensionMake(20)
            self.routeMapDisplayNode.style.flexGrow = 1
            self.routeMapDisplayNode.style.flexShrink = 1
            return ASStackLayoutSpec(
                direction: .vertical,
                spacing: 0,
                justifyContent: .start,
                alignItems: .stretch,
                children: [firstNode, self.routeMapDisplayNode]
            )
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        routeMapDisplayNode.onExitButtonTap = { [unowned self] in
            if self.mode == .testing {
                let alertController = UIAlertController(
                    title: NSLocalizedString("alert.title.warning", comment: ""), 
                    message: NSLocalizedString("alert.warning.testing_exit", comment: ""), 
                    preferredStyle: .alert
                )
                let okButtonAction = UIAlertAction(
                    title: NSLocalizedString("alert.warning.yes", comment: ""), 
                    style: .destructive, 
                    handler: { [unowned self] _ in
                        self.dismiss(animated: true, completion: nil)
                })
                let cancelButtonAction = UIAlertAction(
                    title: NSLocalizedString("alert.warning.no", comment: ""), 
                    style: .cancel, 
                    handler: nil
                )

                alertController.addAction(cancelButtonAction)
                alertController.addAction(okButtonAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        routeMapDisplayNode.onNextButtonTap = { [unowned self] in
            switch self.mode {
            case .practice:
                guard self.currentSegment < self.totalSegmentsCount else {
                    self.routeMapDisplayNode.isNextButtonDisabled = true
                    self.routeMapDisplayNode.zoomToInitial()
                    self.routeMapDisplayNode.showFinishButton()
                    return
                }

                self.routeMapDisplayNode.zoomToSegment(at: self.currentSegment)
                self.currentSegment += 1
            case .testing:
                guard self.currentSegment < self.totalSegmentsCount else {
                    self.routeMapDisplayNode.isNextButtonDisabled = true
                    self.routeMapDisplayNode.zoomToInitial()
                    self.routeMapDisplayNode.showFinishButton()
                    return
                }

                if self.currentSegment > 0 {
                    self.routeMapDisplayNode
                        .showNextSegmentAndZoom(segmentIndex: self.currentSegment)
                    self.routeMapDisplayNode.isNextButtonDisabled = true
                } else {
                    self.routeMapDisplayNode.zoomToSegment(at: self.currentSegment)
                }
                self.currentSegment += 1
            }
        }
        routeMapDisplayNode.onAnswerRightButtonTap = { [unowned self] in
            self.routeMapDisplayNode.isNextButtonDisabled = false
        }
        routeMapDisplayNode.onAnswerWrongButtonTap = { [unowned self] in
            self.wrongAnswersIndexes.append(self.currentSegment)
            self.routeMapDisplayNode.isNextButtonDisabled = false
        }
        routeMapDisplayNode.onFinishButtonTap = { [unowned self] in
            switch self.mode {
            case .practice:
                self.dismiss(animated: true, completion: nil)
            case .testing:
                let routePass = RoutePass(mistakeIndexes: self.wrongAnswersIndexes)

                self.route.passes.append(routePass)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
