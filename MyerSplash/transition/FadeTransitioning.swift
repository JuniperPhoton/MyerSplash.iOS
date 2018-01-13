import Foundation
import UIKit

class FadeOutTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Values.DEFAULT_ANIMATION_DURATION_SEC
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }

        let containerView = transitionContext.containerView

        containerView.addSubview(fromVC.view)

        let durationSec = transitionDuration(using: transitionContext)

        fromVC.view.alpha = 1.0

        UIView.animate(withDuration: durationSec, delay: 0, options: UIViewAnimationOptions(), animations: {
            fromVC.view.alpha = 0.0
        }, completion: { b in
            transitionContext.completeTransition(true)
        })
    }
}

class FadeInTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to)
                else {
            return
        }

        let containerView = transitionContext.containerView

        containerView.addSubview(toVC.view)

        let durationSec = transitionDuration(using: transitionContext)

        toVC.view.alpha = 0.0
        toVC.view.frame = fromVC.view.frame

        UIView.animate(withDuration: durationSec, delay: 0, options: UIViewAnimationOptions(), animations: {
            toVC.view.alpha = 1.0
        }, completion: { b in
            transitionContext.completeTransition(true)
        })
    }
}