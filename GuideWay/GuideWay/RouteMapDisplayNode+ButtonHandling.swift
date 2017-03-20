//
//  RouteMapDisplayNode+ButtonHandling.swift
//  GuideWay
//
//  Created by Daniel Ilchishyn on 3/17/17.
//  Copyright © 2017 Sasha&Daniel. All rights reserved.
//

import AsyncDisplayKit

extension RouteMapDisplayNode {
    func showFinishButton() {
        let calculatedLayout = finishButtonNode.calculateLayoutThatFits(
            ASSizeRangeMake(
                .zero,
                CGSize(width: CGFloat.infinity,
                       height: CGFloat.infinity)
            )
        )
        let origin = CGPoint(
            x: frame.midX - calculatedLayout.size.width / 2,
            y: frame.maxY
        )

        finishButtonNode.frame = CGRect(origin: origin,
                                        size: calculatedLayout.size)
        addSubnode(finishButtonNode)
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.finishButtonNode.frame.origin.y -=
                            self.finishButtonNode.bounds.height + 45
        }, completion: nil)
    }

    func hideFinishButton(completion: (() -> ())?) {
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                        self.finishButtonNode.frame.origin.y +=
                            self.finishButtonNode.bounds.height + 45
        }, completion: { _ in
            self.finishButtonNode.removeFromSupernode()
            completion?()
        })
    }

    func finishButtonTapped() {
        hideFinishButton {
            self.onFinishButtonTap?()
        }
    }

    func showAnswerButtons() {
        let sizeRange = ASSizeRange(
            min: .zero, max: CGSize(
                width: CGFloat.infinity,
                height: CGFloat.infinity
            )
        )
        let answerRightButtonCalculatedSize =
            answerRightButtonNode.calculateLayoutThatFits(sizeRange).size
        let answerWrongButtonCalculatedSize =
            answerWrongButtonNode.calculateLayoutThatFits(sizeRange).size
        let answerRightButtonOrigin = CGPoint(
            x: frame.midX - answerRightButtonCalculatedSize.width - 5,
            y: frame.maxY
        )
        let answerWrongButtonOrigin = CGPoint(
            x: frame.midX + 5,
            y: frame.maxY
        )

        answerRightButtonNode.frame = CGRect(
            origin: answerRightButtonOrigin,
            size: answerRightButtonCalculatedSize
        )
        answerWrongButtonNode.frame = CGRect(
            origin: answerWrongButtonOrigin,
            size: answerWrongButtonCalculatedSize
        )
        addSubnode(answerRightButtonNode)
        addSubnode(answerWrongButtonNode)
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        self.answerRightButtonNode.frame.origin.y -=
                            answerRightButtonCalculatedSize.height + 30
        }, completion: nil)
        UIView.animate(withDuration: 0.25,
                       delay: 0.1,
                       options: .curveEaseOut,
                       animations: {
                        self.answerWrongButtonNode.frame.origin.y -=
                            answerWrongButtonCalculatedSize.height + 30
        }, completion: nil)
    }

    func hideAnswerButtons(completion: (() -> ())?) {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.answerRightButtonNode.frame.origin.y = self.frame.maxY
                self.answerWrongButtonNode.frame.origin.y = self.frame.maxY
        }, completion: { _ in
            self.answerRightButtonNode.removeFromSupernode()
            self.answerWrongButtonNode.removeFromSupernode()
            completion?()
        })
    }

    func answerButtonTapped(sender: ASButtonNode) {
        hideAnswerButtons {
            switch sender {
            case self.answerRightButtonNode:
                self.onAnswerRightButtonTap?()
            case self.answerWrongButtonNode:
                self.onAnswerWrongButtonTap?()
            default:
                break
            }
        }
    }
}
