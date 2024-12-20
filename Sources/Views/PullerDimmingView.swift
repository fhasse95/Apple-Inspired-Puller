import UIKit

final public class PullerDimmingView: UIView {
  
  public var onDidTap: (() -> Void)?
  
  weak var viewToTranslateGesture: UIView?
  
  init() {
    super.init(frame: .zero)
    setupView()
  }
  
  private func setupView() {
    backgroundColor = .black
    alpha = 0.0
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapView))
    addGestureRecognizer(tapGestureRecognizer)
  }
  
  required init?(coder: NSCoder) {
    nil
  }
  
  @objc private func tapView() {
    onDidTap?()
  }
  
  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let view = super.hitTest(point, with: event)
    
    guard view == nil else {
      return view
    }
    
    return viewToTranslateGesture?.hitTest(point, with: event)
  }
}
