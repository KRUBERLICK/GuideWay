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
    let keyboardController: KeyboardController
    let disposeBag = DisposeBag()
    var autocompleteDisposeBag = DisposeBag()
    let autocompleteController: AutocompleteController
    let googleServicesAPI: GoogleServicesAPI

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var shouldAutorotate: Bool {
        return false
    }

    init(routeSetupDisplayNode: RouteSetupDisplayNode,
         keyboardController: KeyboardController,
         autocompleteController: AutocompleteController,
         googleServicesAPI: GoogleServicesAPI) {
        self.routeSetupDisplayNode = routeSetupDisplayNode
        self.keyboardController = keyboardController
        self.autocompleteController = autocompleteController
        self.googleServicesAPI = googleServicesAPI
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
        routeSetupDisplayNode.onCreateRouteButtonTap = { [unowned self] in
            self.keyboardController.hideKeyboard(completion: { 
                
            })
        }
        autocompleteController.onSelect = { [unowned self] suggestion in
            if self.routeSetupDisplayNode.originTextFieldNode.isFirstResponder() {
                self.routeSetupDisplayNode.originTextField.text = suggestion
            }
            if self.routeSetupDisplayNode.destinationTextFieldNode.isFirstResponder() {
                self.routeSetupDisplayNode.destinationTextField.text = suggestion
            }
            self.autocompleteController.hideAutocomplete()
        }
        routeSetupDisplayNode.originTextField.rx.text
            .throttle(2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] text in
                self.fetchAutosuggestions(
                    for: self.routeSetupDisplayNode.originTextField
                )
            })
            .addDisposableTo(disposeBag)
        routeSetupDisplayNode.destinationTextField.rx.text
            .throttle(2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] text in
                self.fetchAutosuggestions(
                    for: self.routeSetupDisplayNode.destinationTextField
                )
            })
            .addDisposableTo(disposeBag)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldDidEndEditing(notification:)),
            name: NSNotification.Name.UITextFieldTextDidEndEditing,
            object: nil
        )
    }

    func textFieldDidChange(notification: Notification) {
        guard let textField = notification.object as? UITextField,
            !textField.text!.isEmpty else {
                autocompleteController.hideAutocomplete()
                return
        }

        fetchAutosuggestions(for: textField)
    }

    func fetchAutosuggestions(for textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            return
        }

        autocompleteDisposeBag = DisposeBag()
        googleServicesAPI.requestPlaceAutosuggestions(for: text)
            .subscribe(onNext: { response in
                self.autocompleteController.autocompleteQueries
                    = response.results.map { $0.name }
                switch textField {
                case self.routeSetupDisplayNode.originTextField:
                    self.autocompleteController.showAutocomplete(
                        for: self.routeSetupDisplayNode.originTextFieldNode
                    )
                case self.routeSetupDisplayNode.destinationTextField:
                    self.autocompleteController.showAutocomplete(
                        for: self.routeSetupDisplayNode.destinationTextFieldNode
                    )
                default:
                    break
                }
            }, onError: { error in
                print(error)
            })
            .addDisposableTo(autocompleteDisposeBag)
    }

    func textFieldDidEndEditing(notification: Notification) {
        autocompleteController.hideAutocomplete()
    }

    func hideKeyboard() {
        keyboardController.hideKeyboard()
    }
}

