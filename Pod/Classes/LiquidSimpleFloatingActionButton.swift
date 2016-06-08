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
public class LiquidSimpleFloatingActionButton : UIControl {
    
    private let internalRadiusRatio: CGFloat = 20.0 / 56.0
    public var enableShadow = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var responsible = true
    
    @IBInspectable public var color: UIColor = UIColor(red: 82 / 255.0, green: 112 / 255.0, blue: 235 / 255.0, alpha: 1.0)
    
    @IBInspectable public var image: UIImage? {
        didSet {
            if image != nil {
                maskLayer.contents = image!.CGImage
                
                plusLayer.mask = maskLayer
                plusLayer.backgroundColor = tintColor.CGColor
                plusLayer.path = nil
            }
        }
    }

    @IBInspectable public var imageInset: CGFloat = 0 {
        didSet {
            maskLayer.frame = plusLayer.bounds.insetBy(dx: imageInset, dy: imageInset)
        }
    }
    
    private var plusLayer   = CAShapeLayer()
    private let circleLayer = CAShapeLayer()
    private let maskLayer   = CALayer()
    
    private var touching = false
    
    private var baseView = SimpleCircleLiquidBaseView()
    private let liquidView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: draw icon
    public override func drawRect(rect: CGRect) {
        drawCircle()
        drawShadow()
    }
    
    /// create, configure & draw the plus layer (override and create your own shape in subclass!)
    public func createPlusLayer(frame: CGRect) -> CAShapeLayer {
        
        // draw plus shape
        let plusLayer = CAShapeLayer()
        plusLayer.lineCap = kCALineCapRound
        plusLayer.strokeColor = UIColor.whiteColor().CGColor
        plusLayer.lineWidth = 3.0
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: frame.width * internalRadiusRatio, y: frame.height * 0.5))
        path.addLineToPoint(CGPoint(x: frame.width * (1 - internalRadiusRatio), y: frame.height * 0.5))
        path.moveToPoint(CGPoint(x: frame.width * 0.5, y: frame.height * internalRadiusRatio))
        path.addLineToPoint(CGPoint(x: frame.width * 0.5, y: frame.height * (1 - internalRadiusRatio)))
        
        plusLayer.path = path.CGPath
        return plusLayer
    }
    
    private func drawCircle() {
        self.circleLayer.cornerRadius = self.frame.width * 0.5
        self.circleLayer.masksToBounds = true
        if touching && responsible {
            self.circleLayer.backgroundColor = self.color.white(0.5).CGColor
        } else {
            self.circleLayer.backgroundColor = self.color.CGColor
        }
    }
    
    private func drawShadow() {
        if enableShadow {
            circleLayer.appendShadow()
        }
    }
    
    // MARK: Events
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.touching = true
        setNeedsDisplay()
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        self.touching = false
        setNeedsDisplay()
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        self.touching = false
        setNeedsDisplay()
    }
    
    // MARK: private methods
    private func setup() {
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
        
        baseView.userInteractionEnabled = false
        baseView.setup(self)
        addSubview(baseView)
        
        liquidView.frame = baseView.frame
        liquidView.userInteractionEnabled = false
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
    
    func setup(actionButton: LiquidSimpleFloatingActionButton) {
        self.frame = actionButton.frame
        self.center = actionButton.center.minus(actionButton.frame.origin)
        let radius = min(self.frame.width, self.frame.height) * 0.5
        
        baseLiquid = LiquittableCircle(center: self.center.minus(self.frame.origin), radius: radius, color: actionButton.color)
        baseLiquid?.clipsToBounds = false
        baseLiquid?.layer.masksToBounds = false
        baseLiquid?.userInteractionEnabled = false
        
        clipsToBounds = false
        layer.masksToBounds = false
        addSubview(baseLiquid!)
    }
    
}