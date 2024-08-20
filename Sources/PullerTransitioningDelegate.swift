import UIKit

final public class PullerTransitioningDelegate: NSObject {
  
  private let model: PullerModel
  private let animationController: PullerAnimationController
  
  public init(model: PullerModel, viewController: UIViewController) {
    self.model = model
    self.animationController = PullerAnimationController(model: model,
                                                         viewController: viewController,
                                                         isPresenting: true)
  }
}

extension PullerTransitioningDelegate: UIViewControllerTransitioningDelegate {
  
  public func animationController(forPresented presented: UIViewController,
                                  presenting: UIViewController,
                                  source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    animationController.isPresenting = true
    return animationController
  }
  
  public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    animationController.isPresenting = false
    return animationController
  }
  
  public func presentationController(forPresented presented: UIViewController,
                                     presenting: UIViewController?,
                                     source: UIViewController) -> UIPresentationController? {
    
    let pullerPresentationController = PullerPresentationController(presentedViewController: presented,
                                                                    presenting: presenting,
                                                                    model: model)
    animationController.pullerPresentationController = pullerPresentationController
    pullerPresentationController.animationController = animationController
    return pullerPresentationController
  }
}
