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
            positionResizeViews()
        }
    }
    
    private lazy var topLeftResizeView: ResizeView = {
        let v = ResizeView(orientation: .topLeft, positionChangeHandler: { [weak self] (change) in
            guard let self = self else { return }
            
            let newRect = CGRect(minX: self.holeRect.minX + change.x, minY: self.holeRect.minY + change.y, maxX: self.holeRect.maxX, maxY: self.holeRect.maxY)
            guard newRect.minX < self.holeRect.maxX && newRect.minY < self.holeRect.maxY else { return }
            self.holeRect = newRect
        })
        addSubview(v)
        return v
    }()
    private lazy var topRightResizeView: ResizeView = {
        let v = ResizeView(orientation: .topRight, positionChangeHandler: { [weak self] (change) in
            guard let self = self else { return }
            
            let newRect = CGRect(minX: self.holeRect.minX, minY: self.holeRect.minY + change.y, maxX: self.holeRect.maxX + change.x, maxY: self.holeRect.maxY)
            guard newRect.maxX > self.holeRect.minX && newRect.minY < self.holeRect.maxY else { return }
            self.holeRect = newRect
        })
        addSubview(v)
        return v
    }()
    private lazy var bottomLeftResizeView: ResizeView = {
        let v = ResizeView(orientation: .bottomLeft, positionChangeHandler: { [weak self] (change) in
            guard let self = self else { return }
            
            let newRect = CGRect(minX: self.holeRect.minX + change.x, minY: self.holeRect.minY, maxX: self.holeRect.maxX, maxY: self.holeRect.maxY + change.y)
            guard newRect.minX < self.holeRect.maxX && newRect.maxY > self.holeRect.minY else { return }
            self.holeRect = newRect
        })
        addSubview(v)
        return v
    }()
    private lazy var bottomRightResizeView: ResizeView = {
        let v = ResizeView(orientation: .bottomRight, positionChangeHandler: { [weak self] (change) in
            guard let self = self else { return }
            
            let newRect = CGRect(minX: self.holeRect.minX, minY: self.holeRect.minY, maxX: self.holeRect.maxX + change.x, maxY: self.holeRect.maxY + change.y)
            guard newRect.maxX > self.holeRect.minX && newRect.maxY > self.holeRect.minY else { return }
            self.holeRect = newRect
        })
        addSubview(v)
        return v
    }()

    private func positionResizeViews() {
        topLeftResizeView.frame = CGRect(origin: holeRect.origin, size: CGSize(width: 16, height: 16))
        topRightResizeView.frame = CGRect(origin: CGPoint(x: holeRect.maxX - ResizeView.lineWidth * 2, y: holeRect.minY), size: CGSize(width: 16, height: 16))
        bottomLeftResizeView.frame = CGRect(origin: CGPoint(x: holeRect.minX, y: holeRect.maxY - ResizeView.lineWidth * 2), size: CGSize(width: 16, height: 16))
        bottomRightResizeView.frame = CGRect(origin: CGPoint(x: holeRect.maxX - ResizeView.lineWidth * 2, y: holeRect.maxY - ResizeView.lineWidth * 2), size: CGSize(width: 16, height: 16))
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

extension CropView {
    class ResizeView: UIView {
        
        enum Orientation {
            case topLeft, topRight, bottomLeft, bottomRight
            
            var transform: CGAffineTransform {
                switch self {
                case .topLeft: return .identity
                case .topRight: return CGAffineTransform(scaleX: -1, y: 1)
                case .bottomLeft: return CGAffineTransform(scaleX: 1, y: -1)
                case .bottomRight: return CGAffineTransform(scaleX: -1, y: -1)
                }
            }
        }
        
        @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
            positionChangeHandler(recognizer.translation(in: superview))
            recognizer.setTranslation(.zero, in: superview)
        }
        
        typealias PositionChangeHandler = (CGPoint) -> Void
        private let positionChangeHandler: PositionChangeHandler
        
        static let lineWidth: CGFloat = 8
        
        init(orientation: Orientation, positionChangeHandler: @escaping PositionChangeHandler) {
            self.positionChangeHandler = positionChangeHandler
            super.init(frame: .zero)
            isOpaque = false
            backgroundColor = .clear
            addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:))))
            transform = orientation.transform
        }
        
        override init(frame: CGRect) {
            fatalError()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
                        
            context.setFillColor(UIColor.clear.cgColor)
            context.fill(bounds)
            
            let path = UIBezierPath()
            let lineWidth = ResizeView.lineWidth
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: bounds.maxX, y: 0))
            path.addLine(to: CGPoint(x: bounds.maxX, y: lineWidth))
            path.addLine(to: CGPoint(x: lineWidth, y: lineWidth))
            path.addLine(to: CGPoint(x: lineWidth, y: bounds.maxY))
            path.addLine(to: CGPoint(x: 0, y: bounds.maxY))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.close()
            
            context.addPath(path.cgPath)
            context.setFillColor(UIColor(white: 1, alpha: 0.9).cgColor)
            context.fillPath()
        }
    }
}

extension CGRect {
    init(minX: CGFloat, minY: CGFloat, maxX: CGFloat, maxY: CGFloat) {
        self.init(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
