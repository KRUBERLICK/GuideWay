//
//  LoginViewController.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 4/19/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

class LoginViewController: ASViewController<ASDisplayNode> {
    let presentationManager: PresentationManager
    let loginDisplayNode: LoginDisplayNode
    let keyboardController: KeyboardController
    let disposeBag = DisposeBag()

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
         keyboardController: KeyboardController) {
        self.presentationManager = presentationManager
        loginDisplayNode = presentationManager.getLoginDisplayNode()
        self.keyboardController = keyboardController
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
                    // login/register user
                })
            })
            .addDisposableTo(disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
}
