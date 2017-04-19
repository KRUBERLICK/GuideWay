//
//  ViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 2/22/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import RxCocoa
import Siesta

class RouteSetupViewController: ASViewController<ASDisplayNode> {
    let routeSetupDisplayNode: RouteSetupDisplayNode
    let disposeBag = DisposeBag()
    var autocompleteDisposeBag = DisposeBag()
    var textFieldsDisposeBag = DisposeBag()
    let keyboardController: KeyboardController
    let autocompleteController: AutocompleteController
    let googleServicesAPI: GoogleServicesAPI
    let presentationManager: PresentationManager

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    init(routeSetupDisplayNode: RouteSetupDisplayNode,
         keyboardController: KeyboardController,
         autocompleteController: AutocompleteController,
         googleServicesAPI: GoogleServicesAPI,
         presentationManager: PresentationManager) {
        self.routeSetupDisplayNode = routeSetupDisplayNode
        self.keyboardController = keyboardController
        self.autocompleteController = autocompleteController
        self.googleServicesAPI = googleServicesAPI
        self.presentationManager = presentationManager
        super.init(node: routeSetupDisplayNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardController.parentView = view
        routeSetupDisplayNode.backgroundImageNode.addTarget(
            self, 
            action: #selector(RouteSetupViewController.hideKeyboard), 
            forControlEvents: .touchUpInside
        )
        automaticallyAdjustsScrollViewInsets = false
        routeSetupDisplayNode.onCreateRouteButtonTap = { [unowned self] in
            self.keyboardController.hideKeyboard(completion: { 
                guard let origin = self.routeSetupDisplayNode
                    .originTextField.text,
                    let destination = self.routeSetupDisplayNode
                        .destinationTextField.text,
                    !origin.isEmpty,
                    !destination.isEmpty else {
                        AlertWithBackgroundNode.showAlert(
                            for: self.node,
                            with: NSLocalizedString(
                                "alert.error.input_all_fields",
                                comment: ""
                            )
                        )
                        return
                }

                let route = Route(
                    origin: origin,
                    destination: destination
                )

                let routeDetailsVC =
                    self.presentationManager
                        .getRouteDetailsViewController(for: route)

                self.navigationController?.pushViewController(
                    routeDetailsVC,
                    animated: true
                )
            })
        }
        autocompleteController.onSelect = { [unowned self] suggestion in
            if self.routeSetupDisplayNode
                .originTextFieldNode.isFirstResponder() {
                self.routeSetupDisplayNode
                    .originTextField.text = suggestion
            }
            if self.routeSetupDisplayNode
                .destinationTextFieldNode.isFirstResponder() {
                self.routeSetupDisplayNode
                    .destinationTextField.text = suggestion
            }
            self.autocompleteDisposeBag = DisposeBag()
            self.autocompleteController.hideAutocomplete()
        }
        navigationItem.title = NSLocalizedString(
            "route_setup.title",
            comment: ""
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar
            .barTintColor = UIColor(hexString: "626466")
        navigationController?.navigationBar
            .titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        navigationController?.setNavigationBarHidden(
            false,
            animated: true
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(RouteSetupViewController
                .textFieldDidBeginEditing(notification:)),
            name: NSNotification.Name.UITextFieldTextDidBeginEditing,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(RouteSetupViewController
                .textFieldDidEndEditing(notification:)),
            name: NSNotification.Name.UITextFieldTextDidEndEditing,
            object: nil
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardController.supress = true
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardController.supress = false

        // Temporary
//        var routeMock = Route(
//            origin: "проспект Победы 12",
//            destination: "проспект Победы 25"
//        )
//
//        routeMock.passes.append(RoutePass(mistakeIndexes: [1, 3, 6, 2]))
//        routeMock.passes.append(RoutePass(mistakeIndexes: []))
//        routeMock.passes.append(RoutePass(mistakeIndexes: [5, 4]))
//
//        let routeDetailsVC = self.presentationManager
//            .getRouteDetailsViewController(
//                for: routeMock
//        )
//
//        self.navigationController?.pushViewController(
//            routeDetailsVC,
//            animated: true
//        )
    }

    func textFieldDidBeginEditing(notification: Notification) {
        guard let textField = notification.object as? UITextField,
            (textField == routeSetupDisplayNode.originTextField
                || textField == routeSetupDisplayNode.destinationTextField) else {
                    return
        }

        textFieldsDisposeBag = DisposeBag()
        textField.rx.text
            .debounce(0.2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] text in
                self.fetchAutosuggestions(for: textField)
            })
            .addDisposableTo(textFieldsDisposeBag)
    }

    func fetchAutosuggestions(for textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            autocompleteController.hideAutocomplete()
            return
        }

        autocompleteDisposeBag = DisposeBag()
        googleServicesAPI.requestPlaceAutocomplete(for: text)
            .subscribe(onNext: { [unowned self] response in
                self.autocompleteController.autocompleteQueries
                    = response.predictions.map {
                        let string = $0.terms.prefix(2).reduce("", { $0 + " \($1.value)," })

                        return string.substring(to: string.index(before: string.endIndex))
                }
                switch textField {
                case self.routeSetupDisplayNode.originTextField:
                    self.autocompleteController.showAutocomplete(
                        for: self.routeSetupDisplayNode
                            .originTextFieldUnderscoreNode
                    )
                case self.routeSetupDisplayNode.destinationTextField:
                    self.autocompleteController.showAutocomplete(
                        for: self.routeSetupDisplayNode
                            .destinationTextFieldUnderscoreNode
                    )
                default:
                    break
                }
            }, onError: { [unowned self] error in
                InformerNode.showInformer(
                    for: self.node, 
                    with: NSLocalizedString("informer.network_error", comment: "")
                )
            })
            .addDisposableTo(autocompleteDisposeBag)
    }

    func hideKeyboard() {
        keyboardController.hideKeyboard()
    }

    func textFieldDidEndEditing(notification: Notification) {
        autocompleteDisposeBag = DisposeBag()
        hideKeyboard()
        textFieldsDisposeBag = DisposeBag()
        autocompleteController.hideAutocomplete()
    }
}

