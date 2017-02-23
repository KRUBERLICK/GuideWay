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

class RouteSetupViewController: ASViewController<ASDisplayNode> {
    let routeSetupDisplayNode: RouteSetupDisplayNode
    let keyboardController: KeyboardController
    let disposeBag = DisposeBag()
    let autocompleteController: AutocompleteController

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
         autocompleteController: AutocompleteController) {
        self.routeSetupDisplayNode = routeSetupDisplayNode
        self.keyboardController = keyboardController
        self.autocompleteController = autocompleteController
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldDidChange(notification:)),
            name: NSNotification.Name.UITextFieldTextDidChange,
            object: nil
        )
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

        switch textField {
        case routeSetupDisplayNode.originTextField:
            autocompleteController.showAutocomplete(for: routeSetupDisplayNode.originTextFieldNode)
        case routeSetupDisplayNode.destinationTextField:
            autocompleteController.showAutocomplete(for: routeSetupDisplayNode.destinationTextFieldNode)
        default:
            break
        }
    }

    func textFieldDidEndEditing(notification: Notification) {
        autocompleteController.hideAutocomplete()
    }

    func hideKeyboard() {
        keyboardController.hideKeyboard()
    }
}

