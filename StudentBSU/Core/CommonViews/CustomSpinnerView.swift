import UIKit

class CustomSpinnerView: UIView {
    private let spinnerLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSpinner()
    }
    
    required init(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private func setupSpinner() {
        spinnerLayer.lineWidth = 2.0
        spinnerLayer.strokeColor = UIColor.white.withAlphaComponent(0.8).cgColor
        spinnerLayer.fillColor = UIColor.clear.cgColor
        spinnerLayer.lineCap = .round
        
        layer.addSublayer(spinnerLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - spinnerLayer.lineWidth / 2
                
        let path = UIBezierPath(arcCenter: center,
                                radius: radius,
                                startAngle: 0,
                                endAngle: .pi * 1.5,
                                clockwise: true)
                
        spinnerLayer.path = path.cgPath
        spinnerLayer.frame = bounds
    }
    
    func startAnimating() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1.0
        rotation.repeatCount = .infinity
        
        rotation.isRemovedOnCompletion = false
        
        layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func stopAnimating() {
        layer.removeAnimation(forKey: "rotationAnimation")
    }
}

