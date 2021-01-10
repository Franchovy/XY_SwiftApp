//
//  CircleView.swift
//  XY_APP
//
//  Created by Maxime Franchot on 01/01/2021.
//

import UIKit

class CircleView: UIView, XPViewModelDelegate {

    var viewModel: XPViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    // MARK: - XPViewModelDelegate Methods
    
    func onProgress(progress: Float) {
        self.progressBarCircle.progress = CGFloat(progress)
    }
    
    func onLevelChanged(level: Int) {
        levelLabel.text = String(describing: level)
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var progressBarCircle: ProgressBarCircle!
    @IBOutlet weak var levelLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CircleView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        progressBarCircle.frame = self.bounds
        progressBarCircle.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        progressBarCircle.layer.shadowRadius = 5
        progressBarCircle.layer.shadowOffset = .zero
        progressBarCircle.layer.shadowOpacity = 0.3
        progressBarCircle.layer.shadowColor = UIColor.blue.cgColor
        progressBarCircle.layer.shadowPath = UIBezierPath(rect: progressBarCircle.bounds).cgPath
        progressBarCircle.layer.masksToBounds = false

        
        
        levelLabel.frame = self.bounds
        levelLabel.sizeToFit()
        levelLabel.textAlignment = .center
        levelLabel.center = contentView.center
        
    }
}

@IBDesignable
class ProgressBarCircle: UIView {
    
    @IBInspectable var color: UIColor = .gray {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var gradientColor: UIColor = .white {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable var ringWidth: CGFloat = 3

    var progress: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
            createAnimation()
        }
    }

    private var progressLayer = CAShapeLayer()
    private var backgroundMask = CAShapeLayer()
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        createAnimation()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        createAnimation()
    }

    private func setupLayers() {
        backgroundMask.lineWidth = ringWidth
        backgroundMask.fillColor = nil
        backgroundMask.strokeColor = UIColor.black.cgColor
        layer.mask = backgroundMask
        progressLayer.lineWidth = ringWidth
        progressLayer.fillColor = nil

        layer.addSublayer(gradientLayer)
        layer.transform = CATransform3DMakeRotation(CGFloat(90 * Double.pi / 180), 0, 0, -1)

        gradientLayer.mask = progressLayer
        gradientLayer.locations = [0.35, 0.5, 0.65]
    }

    private func createAnimation() {
        let startPointAnimation = CAKeyframeAnimation(keyPath: "startPoint")
        startPointAnimation.values = [CGPoint.zero, CGPoint(x: 1, y: 0), CGPoint(x: 1, y: 1)]

        startPointAnimation.repeatCount = 1
        startPointAnimation.duration = 1

        let endPointAnimation = CAKeyframeAnimation(keyPath: "endPoint")
        endPointAnimation.values = [CGPoint(x: 1, y: 1), CGPoint(x: 0, y: 1), CGPoint.zero]

        endPointAnimation.repeatCount = 1
        endPointAnimation.duration = 1

        gradientLayer.add(startPointAnimation, forKey: "startPointAnimation")
        gradientLayer.add(endPointAnimation, forKey: "endPointAnimation")
    }

    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect.insetBy(dx: ringWidth / 2, dy: ringWidth / 2))
        backgroundMask.path = circlePath.cgPath

        progressLayer.path = circlePath.cgPath
        progressLayer.lineCap = .round
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
        progressLayer.strokeColor = UIColor.black.cgColor

        gradientLayer.frame = rect
        gradientLayer.colors = [color.cgColor, gradientColor.cgColor, color.cgColor]

    }
}
