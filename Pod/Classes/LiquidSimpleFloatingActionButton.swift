//
//  LiquidSimpleFloatingActionButton.swift
//  Pods
//
//  Created by Miguel Botón on 2016/06/07.
//
//

import Foundation
import QuartzCore

@IBDesignable
open class LiquidSimpleFloatingActionButton : UIControl {
    
    fileprivate let internalRadiusRatio: CGFloat = 20.0 / 56.0
    open var enableShadow = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open var responsible = true
    
    @IBInspectable open var color: UIColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0)
    
    @IBInspectable open var image: UIImage? {
        didSet {
            if image != nil {
                maskLayer.contents = image!.cgImage
                
                plusLayer.mask = maskLayer
                plusLayer.backgroundColor = tintColor.cgColor
                plusLayer.path = nil
            }
        }
    }

    @IBInspectable open var imageInset: CGFloat = 0 {
        didSet {
            maskLayer.frame = plusLayer.bounds.insetBy(dx: imageInset, dy: imageInset)
        }
    }
    
    fileprivate var plusLayer   = CAShapeLayer()
    fileprivate let circleLayer = CAShapeLayer()
    fileprivate let maskLayer   = CALayer()
    
    fileprivate var touching = false
    
    fileprivate var baseView = SimpleCircleLiquidBaseView()
    fileprivate let liquidView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: draw icon
    open override func draw(_ rect: CGRect) {
        drawCircle()
        drawShadow()
    }
    
    /// create, configure & draw the plus layer (override and create your own shape in subclass!)
    open func createPlusLayer(_ frame: CGRect) -> CAShapeLayer {
        
        // draw plus shape
        let plusLayer = CAShapeLayer()
        plusLayer.lineCap = kCALineCapRound
        plusLayer.strokeColor = UIColor.white.cgColor
        plusLayer.lineWidth = 3.0
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width * internalRadiusRatio, y: frame.height * 0.5))
        path.addLine(to: CGPoint(x: frame.width * (1 - internalRadiusRatio), y: frame.height * 0.5))
        path.move(to: CGPoint(x: frame.width * 0.5, y: frame.height * internalRadiusRatio))
        path.addLine(to: CGPoint(x: frame.width * 0.5, y: frame.height * (1 - internalRadiusRatio)))
        
        plusLayer.path = path.cgPath
        return plusLayer
    }
    
    private func drawCircle() {
        self.circleLayer.cornerRadius = self.frame.width * 0.5
        self.circleLayer.masksToBounds = true
        if touching && responsible {
            self.circleLayer.backgroundColor = self.color.white(0.5).cgColor
        } else {
            self.circleLayer.backgroundColor = self.color.cgColor
        }
    }
    
    fileprivate func drawShadow() {
        if enableShadow {
            circleLayer.appendShadow()
        }
    }
    
    // MARK: Events
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.touching = true
        setNeedsDisplay()
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.touching = false
        setNeedsDisplay()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.touching = false
        setNeedsDisplay()
    }
    
    // MARK: private methods
    fileprivate func setup() {
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = false
        
        baseView.isUserInteractionEnabled = false
        baseView.setup(self)
        addSubview(baseView)
        
        liquidView.frame = baseView.frame
        liquidView.isUserInteractionEnabled = false
        addSubview(liquidView)
        
        liquidView.layer.addSublayer(circleLayer)
        circleLayer.frame = liquidView.layer.bounds
        
        plusLayer = createPlusLayer(circleLayer.bounds)
        circleLayer.addSublayer(plusLayer)
        plusLayer.frame = circleLayer.bounds
    }
    
}

class SimpleCircleLiquidBaseView : UIView {
    
    var baseLiquid: LiquittableCircle?
    var enableShadow = true
    
    func setup(_ actionButton: LiquidSimpleFloatingActionButton) {
        self.frame = actionButton.frame
        self.center = actionButton.center.minus(actionButton.frame.origin)
        let radius = min(self.frame.width, self.frame.height) * 0.5
        
        baseLiquid = LiquittableCircle(center: self.center.minus(self.frame.origin), radius: radius, color: actionButton.color)
        baseLiquid?.clipsToBounds = false
        baseLiquid?.layer.masksToBounds = false
        baseLiquid?.isUserInteractionEnabled = false
        
        clipsToBounds = false
        layer.masksToBounds = false
        addSubview(baseLiquid!)
    }
    
}
