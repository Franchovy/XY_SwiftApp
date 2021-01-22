//
//  CircleView.swift
//  XY_APP
//
//  Created by Maxime Franchot on 01/01/2021.
//

import UIKit

class CircleView: UIView {
    
    func onProgress(level: Int, progress: Float) {
        self.progressBarCircle.progress = CGFloat(progress)
        self.levelLabel.text = String(describing: level)
    }
    
    func setProgress(level: Int, progress: Float) {
        self.progressBarCircle.progress = CGFloat(progress)
        self.levelLabel.text = String(describing: level)
        setupFinished()
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

        layer.shadowRadius = 10
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.blue.cgColor
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.masksToBounds = false
        tintColor = .blue
        
        backgroundColor = .clear
        
        levelLabel.frame = self.bounds
        levelLabel.sizeToFit()
        levelLabel.textAlignment = .center
        levelLabel.center = contentView.center
        levelLabel.textColor = .white
        
    }
    
    // MARK: - Public methods
    func reset() {
        progressBarCircle.reset()
    }
    
    func setupFinished() {
        progressBarCircle.setup = false
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

    var setup = true
    
    var progress: CGFloat = 0.0 {
        willSet {
            
            if newValue == progress || setup { return }
            
            if newValue > progress {
                // XP went up
                //flashColor(animateColor: .green)
                if !setup {
                    self.color = .green
                }
            } else {
                // XP went down
                //flashColor(animateColor: .yellow)
                if !setup {
                    self.color = .yellow
                }
            }
        }
        didSet {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.color = .blue
            }
            if !setup {
                createAnimation()
            } else {
                setNeedsDisplay()
            }
            
        }
    }
    
    func reset() {
        setup = true
        progress = 0
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