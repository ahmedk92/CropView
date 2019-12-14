//
//  CropView.swift
//  CropView
//
//  Created by Ahmed Khalaf on 12/14/19.
//  Copyright © 2019 Ahmed Khalaf. All rights reserved.
//

import UIKit

class CropView: UIView {
    private lazy var dimView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = UIColor(white: 0, alpha: 0.5)
        v.translatesAutoresizingMaskIntoConstraints = false
        addSubview(v)
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: leadingAnchor),
            v.trailingAnchor.constraint(equalTo: trailingAnchor),
            v.topAnchor.constraint(equalTo: topAnchor),
            v.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        return v
    }()
    
    private var holeRect = CGRect(x: 0, y: 0, width: 100, height: 100) {
        didSet {
            applyMask()
        }
    }
    
    private func applyMask() {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = dimView.bounds
        maskLayer.backgroundColor = UIColor.clear.cgColor
        let path = UIBezierPath(rect: dimView.bounds)
        path.append(UIBezierPath(rect: holeRect))
        path.usesEvenOddFillRule = true
        maskLayer.path = path.cgPath
        maskLayer.fillColor = UIColor.red.cgColor
        maskLayer.fillRule = .evenOdd
        dimView.layer.mask = maskLayer
    }
    
    private func commonInit() {
        _ = dimView
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
    }
    
    private var shouldMove = false
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        defer {
            if recognizer.state == .ended {
                shouldMove = false
            }
        }
        if recognizer.state == .began && holeRect.contains(recognizer.location(in: self)) {
            shouldMove = true
        }
        guard shouldMove else { return }
        
        let translation = recognizer.translation(in: self)
        holeRect.origin = holeRect.origin.applying(CGAffineTransform(translationX: translation.x, y: translation.y))
        recognizer.setTranslation(.zero, in: self)
    }
    
    // MARK: Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if dimView.layer.mask == nil {
            applyMask()
        }
    }
}
