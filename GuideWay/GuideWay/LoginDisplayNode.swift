//
//  LoginDisplayNode.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/19/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

class LoginDisplayNode: ASDisplayNode {
    enum State {
        case `default`
        case loading
    }

    var state: State = .default {
        didSet {
            transitionLayout(
                withAnimation: true, 
                shouldMeasureAsync: true, 
                measurementCompletion: nil
            )
        }
    }

    let userInputResultPublisher = PublishSubject<(String, String)>()

    let titleTextNode: ASTextNode = {
        let node = ASTextNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.systemFont(
                ofSize: 70,
                weight: UIFontWeightUltraLight
            )
        ]

        node.attributedText = NSAttributedString(
            string: NSLocalizedString("guideway", comment: ""),
            attributes: textAttribs
        )
        return node
    }()

    let textFieldFactory: (String) -> UITextField = {
        let textField = UITextField()
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 1))

        textField.leftView = spacerView
        textField.rightView = spacerView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.backgroundColor = UIColor(hexString: "356735")
        textField.layer.borderColor = UIColor(hexString: "8AD28A").cgColor
        textField.layer.borderWidth = 1
        textField.defaultTextAttributes = [NSForegroundColorAttributeName: UIColor.white,
                                           NSFontAttributeName: UIFont.systemFont(ofSize: 20)]
        textField.attributedPlaceholder = NSAttributedString(
            string: $0,
            attributes: [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.5),
                         NSFontAttributeName: UIFont.systemFont(ofSize: 20)]
        )
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.layer.masksToBounds = true
        textField.textAlignment = .center
        return textField
    }

    lazy var emailTextField: UITextField = {
        let textField = self.textFieldFactory(
            NSLocalizedString("login.email", comment: "")
        )

        textField.layer.cornerRadius = 10
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        textField.delegate = self
        return textField
    }()

    lazy var passwordTextField: UITextField = {
        let textField = self.textFieldFactory(
            NSLocalizedString("login.password", comment: "")
        )

        textField.isSecureTextEntry = true
        textField.layer.cornerRadius = 10
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()

    var emailNode: ASDisplayNode!
    var passwordNode: ASDisplayNode!

    lazy var loginButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        let textAttribs = [
            NSForegroundColorAttributeName: UIColor(hexString: "C0FFC5"), 
            NSFontAttributeName: UIFont.systemFont(ofSize: 20)
        ]

        node.setAttributedTitle(
            NSAttributedString(
                string: NSLocalizedString("login.login_register", comment: ""),
                attributes: textAttribs
            ), for: [])
        node.addTarget(
            self, 
            action: #selector(LoginDisplayNode.loginButtonTapped), 
            forControlEvents: .touchUpInside
        )
        return node
    }()

    let loadingIndicatorNode: ASDisplayNode = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

        view.startAnimating()

        let node = ASDisplayNode(viewBlock: { view })

        node.backgroundColor = .clear
        return node
    }()

    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        emailNode = ASDisplayNode(viewBlock: { [unowned self] in self.emailTextField })
        passwordNode = ASDisplayNode(viewBlock: { [unowned self] in self.passwordTextField })
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        emailNode.style.flexBasis = ASDimensionMake(45)
        passwordNode.style.flexBasis = ASDimensionMake(45)
        loadingIndicatorNode.style.flexBasis = ASDimensionMake(45)

        let stack = ASStackLayoutSpec(
            direction: .vertical, 
            spacing: 20, 
            justifyContent: .center, 
            alignItems: .center, 
            children: [
                titleTextNode, 
                emailNode, 
                passwordNode, 
                state == .default
                    ? loginButtonNode
                    : loadingIndicatorNode
            ]
        )
        let stackInsets = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 36, bottom: 0, right: 36), 
            child: stack
        )

        return stackInsets
    }

    override func layout() {
        super.layout()
        setupGradientBackground()
    }

    func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(hexString: "309230").cgColor,
                                UIColor(hexString: "8EB537").cgColor]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func publishUserInput() {
        userInputResultPublisher.onNext((emailTextField.text ?? "",
                                         passwordTextField.text ?? ""))
    }

    func loginButtonTapped() {
        publishUserInput()
    }
}

extension LoginDisplayNode: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        if textField == passwordTextField {
            publishUserInput()
        }
        return true
    }
}
