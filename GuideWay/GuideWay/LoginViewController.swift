//
//  LoginViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/19/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import Firebase

class LoginViewController: ASViewController<ASDisplayNode> {
    let presentationManager: PresentationManager
    let loginDisplayNode: LoginDisplayNode
    let keyboardController: KeyboardController
    let disposeBag = DisposeBag()
    let authManager: AuthManager
    let databaseManager: DatabaseManager

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    init(presentationManager: PresentationManager, 
         keyboardController: KeyboardController,
         authManager: AuthManager,
         databaseManager: DatabaseManager) {
        self.presentationManager = presentationManager
        loginDisplayNode = presentationManager.getLoginDisplayNode()
        self.keyboardController = keyboardController
        self.authManager = authManager
        self.databaseManager = databaseManager
        super.init(node: loginDisplayNode)
        loginDisplayNode.userInputResultPublisher
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (email, password) in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.keyboardController.hideKeyboard(completion: {
                    guard !email.isEmpty, !password.isEmpty else {
                        AlertWithBackgroundNode.showAlert(
                            for: strongSelf.node, 
                            with: NSLocalizedString(
                                "alert.error.input_all_fields", 
                                comment: ""
                            )
                        )
                        return
                    }
                    strongSelf.loginDisplayNode.state = .loading
                    strongSelf.authManager.signInUser(email: email, password: password)
                        .observeOn(MainScheduler.instance)
                        .subscribe(onNext: { [weak strongSelf] user in
                            guard let strongSelf = strongSelf else {
                                return
                            }

                            strongSelf.loginDisplayNode.state = .default
                            strongSelf.proceedToRoutesListViewController()
                            }, onError: { [weak strongSelf] error in
                                guard let strongSelf = strongSelf else {
                                    return
                                }
                                let error = error as NSError
                                var errorMessage: String

                                switch error.code {
                                case FIRAuthErrorCode.errorCodeUserDisabled.rawValue:
                                    errorMessage = "error.auth.user_disabled"
                                case FIRAuthErrorCode.errorCodeWrongPassword.rawValue:
                                    errorMessage = "error.auth.wrong_password"
                                case FIRAuthErrorCode.errorCodeInvalidEmail.rawValue:
                                    errorMessage = "error.auth.wrong_email"
                                case FIRAuthErrorCode.errorCodeUserNotFound.rawValue:
                                    errorMessage = "error.auth.user_not_found"
                                    strongSelf.authManager.registerUser(
                                        email: email, 
                                        password: password)
                                        .observeOn(MainScheduler.instance)
                                        .subscribe(onNext: { [weak strongSelf] user in
                                            guard let strongSelf = strongSelf else {
                                                return
                                            }

                                            strongSelf.databaseManager.addUser(uid: user.uid, email: email)
                                                .observeOn(MainScheduler.instance)
                                                .subscribe(onNext: { [weak strongSelf] _ in
                                                    guard let strongSelf = strongSelf else {
                                                        return
                                                    }

                                                    strongSelf.loginDisplayNode.state = .default
                                                    strongSelf.proceedToRoutesListViewController()
                                                    }, onError: { [weak strongSelf] error in
                                                        guard let strongSelf = strongSelf else {
                                                            return
                                                        }

                                                        strongSelf.loginDisplayNode.state = .default
                                                        InformerNode.showInformer(
                                                            for: strongSelf.node,
                                                            with: NSLocalizedString("informer.network_error", comment: "")
                                                        )
                                                })
                                                .addDisposableTo(strongSelf.disposeBag)
                                            }, onError: { [weak strongSelf] error in
                                                guard let strongSelf = strongSelf else {
                                                    return
                                                }

                                                let error = error as NSError
                                                var registerErrorMessage: String

                                                switch error.code {
                                                case FIRAuthErrorCode.errorCodeInvalidEmail.rawValue:
                                                    registerErrorMessage = "error.register.invalid_email_format"
                                                case FIRAuthErrorCode.errorCodeWeakPassword.rawValue:
                                                    registerErrorMessage = "error.register.weak_password_error"
                                                case FIRAuthErrorCode.errorCodeEmailAlreadyInUse.rawValue:
                                                    registerErrorMessage = "error.register.email_already_in_use"
                                                case FIRAuthErrorCode.errorCodeNetworkError.rawValue:
                                                    registerErrorMessage = "informer.network_error"
                                                    strongSelf.loginDisplayNode.state = .default
                                                    InformerNode.showInformer(
                                                        for: strongSelf.node,
                                                        with: NSLocalizedString(registerErrorMessage, comment: "")
                                                    )
                                                    return
                                                default:
                                                    strongSelf.loginDisplayNode.state = .default
                                                    registerErrorMessage = "error.unknown_error"
                                                    InformerNode.showInformer(
                                                        for: strongSelf.node,
                                                        with: NSLocalizedString(registerErrorMessage, comment: "")
                                                    )
                                                    return
                                                }
                                                strongSelf.loginDisplayNode.state = .default
                                                AlertWithBackgroundNode.showAlert(
                                                    for: strongSelf.node,
                                                    with: NSLocalizedString(registerErrorMessage, comment: "")
                                                )
                                        })
                                        .addDisposableTo(strongSelf.disposeBag)
                                    return
                                case FIRAuthErrorCode.errorCodeNetworkError.rawValue:
                                    errorMessage = "informer.network_error"
                                    strongSelf.loginDisplayNode.state = .default
                                    InformerNode.showInformer(
                                        for: strongSelf.node, 
                                        with: NSLocalizedString(errorMessage, comment: "")
                                    )
                                    return
                                default:
                                    errorMessage = "error.unknown_error"
                                    strongSelf.loginDisplayNode.state = .default
                                    InformerNode.showInformer(
                                        for: strongSelf.node,
                                        with: NSLocalizedString(errorMessage, comment: "")
                                    )
                                    return
                                }
                                strongSelf.loginDisplayNode.state = .default
                                AlertWithBackgroundNode.showAlert(
                                    for: strongSelf.node, 
                                    with: NSLocalizedString(errorMessage, comment: "")
                                )
                        })
                        .addDisposableTo(strongSelf.disposeBag)
                })
            })
            .addDisposableTo(disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        navigationItem.title = NSLocalizedString(
            "welcome_screen.login",
            comment: ""
        )
        keyboardController.parentView = view
        loginDisplayNode.view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: self, 
                action: #selector(LoginViewController.hideKeyboard)
            )
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar
            .barTintColor = UIColor(hexString: "487848")
        navigationController?.navigationBar
            .titleTextAttributes =
            [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        navigationController?.setNavigationBarHidden(
            false,
            animated: true
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardController.supress = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardController.supress = true
    }

    func hideKeyboard() {
        keyboardController.hideKeyboard()
    }

    func proceedToRoutesListViewController() {
        guard let window = view.window else {
            return
        }

        let routesListViewController = BaseNavigationController(
            rootViewController: presentationManager.getRoutesListViewController()
        )

        UIView.performWithoutAnimation {
            routesListViewController.view.setNeedsLayout()
            routesListViewController.view.layoutIfNeeded()
        }
        UIView.transition(with: window,
                          duration: 0.5,
                          options: .transitionFlipFromRight,
                          animations: {
                            window.rootViewController = routesListViewController
        }, completion: nil)
    }
}
