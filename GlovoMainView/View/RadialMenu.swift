//  Created by Akyl Temirgaliyev on 09.03.2024.

import Foundation
import UIKit

final class RadialMenu: UIView {
	// MARK: - Private Properties
	
	private var delay: Double = 0.2
	private var radius: Double!
	private var startAngle: Angle = Angle(degrees: 270)
	private var circumference: Angle = Angle(degrees: 360)
	private var spacingDegrees: Angle!
	private var animationOrigin: CGPoint!
	
	// Needs calculation
	private let bubbleSize = 110
	
	var didPressButton: ((_ center: GlovoView) -> Void)?
	private var centerButton: GlovoView?
	
	private var glovoViews = [GlovoView]() {
		didSet {
			calculateSpacing()
		}
	}
	
	private var animationOptions: UIView.AnimationOptions = [.curveEaseInOut, .beginFromCurrentState]
	
	private lazy var dynamicAnimator: UIDynamicAnimator = {
		let dynamicAnimator = UIDynamicAnimator(referenceView: self)
		
		return dynamicAnimator
	}()
	
	private lazy var collision: UICollisionBehavior = {
		var dynamicItems = [UIDynamicItem]()
		dynamicItems.append(contentsOf: glovoViews)
		if let centerButton {
			dynamicItems.append(centerButton)
		}
		let collision = UICollisionBehavior(items: dynamicItems)
		collision.translatesReferenceBoundsIntoBoundary = false
		
		return collision
	}()
	
	private lazy var attachmentBehaviors: [UIAttachmentBehavior] = {
		var attachementBehaviors = [UIAttachmentBehavior]()
		var dynamicItems = [GlovoView]()
		dynamicItems.append(contentsOf: glovoViews)
		if let centerButton {
			dynamicItems.append(centerButton)
		}
		for button in dynamicItems {
			let attachement = UIAttachmentBehavior(item: button, attachedToAnchor: button.originalCenter)
			button.attachementBehavior = attachement
			attachement.damping = 0.5
			attachement.frequency = 2
			attachementBehaviors.append(attachement)
		}
		
		return attachementBehaviors
	}()
	
	private lazy var itemBehavior: UIDynamicItemBehavior = {
		var dynamicItems = [UIDynamicItem]()
		dynamicItems.append(contentsOf: glovoViews)
		if let centerButton {
			dynamicItems.append(centerButton)
		}
		let itemBehavior = UIDynamicItemBehavior(items:dynamicItems)
		itemBehavior.allowsRotation = false
		itemBehavior.angularResistance = 0.1
		itemBehavior.density = 1
		itemBehavior.elasticity = 0.1
		itemBehavior.friction = 0.2
		itemBehavior.resistance = 8
		
		return itemBehavior
	}()
	
	private lazy var panGesture: UIPanGestureRecognizer = {
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(sender:)))
		return panGesture
	}()
	
	private var attachment: UIAttachmentBehavior!
	
	// MARK: - Public Methods
	
	func generateButtons(items: [GlovoItem], centerItem: GlovoItem?) {
		radius = Double(frame.width / 2) - 130
		if let centerItem {
			centerButton = GlovoView(frame: CGRect(
				x: 0,
				y: 0,
				width: bubbleSize + 20,
				height: bubbleSize + 20
			))
			centerButton?.configure(with: centerItem)
		}
		items.forEach {
			let glovoView = GlovoView(frame: CGRect(
				x: 0,
				y: 0,
				width: bubbleSize,
				height: bubbleSize
			))
			glovoView.configure(with: $0)
			glovoViews.append(glovoView)
			glovoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapView)))
		}
		glovoViews.forEach { $0.originalCenter = $0.center }
	}
	
	func presentInView() {
		guard glovoViews.count != 0 else {
			return
		}
		if animationOrigin == nil {
			animationOrigin = CGPoint.init(x: frame.size.width / 2, y: frame.size.height / 2)
			// animationOrigin = center not working
		}
		if let centerButton {
			addSubview(centerButton)
			centerButton.center = animationOrigin
			centerButton.originalCenter = animationOrigin
		}
		for (index, _) in glovoViews.enumerated() {
			let button = glovoViews[index]
			addSubview(button)
			presentAnimation(view: button, index: index)
		}
		
		for attachement in attachmentBehaviors {
			dynamicAnimator.addBehavior(attachement)
		}
		dynamicAnimator.addBehavior(itemBehavior)
		glovoViews.forEach({$0.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))})
		if let centerButton {
			centerButton.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
		}
	}
}

// MARK: - Private Methods

private extension RadialMenu {
	func presentAnimation(view: GlovoView, index: Int) {
		let degrees = startAngle.degrees + spacingDegrees.degrees * Double(index)
		let newCenter = pointOnCircumference(
			origin: animationOrigin,
			radius: radius,
			angle: Angle(degrees: degrees)
		)
		let _delay = Double(index) * delay
		view.center = animationOrigin
		view.originalCenter = newCenter
		view.alpha = 0
		view.center = newCenter
		view.transform = CGAffineTransform.init(scaleX: 0.0001, y: 0.0001)
		UIView.animate(
			withDuration: 0.7,
			delay: _delay,
			usingSpringWithDamping: 0.7,
			initialSpringVelocity: 0.7,
			options: animationOptions,
			animations: {
				view.alpha = 1
				view.transform = .identity
			},
			completion: nil
		)
	}
	
	func pointOnCircumference(
		origin: CGPoint,
		radius: Double,
		angle: Angle
	) -> CGPoint {
		let radians = angle.radians()
		let x = origin.x + CGFloat(radius) * CGFloat(cos(radians))
		let y = origin.y + CGFloat(radius) * CGFloat(sin(radians))
		
		return CGPoint(x: x, y: y)
	}
	
	func calculateSpacing() {
		if glovoViews.count > 0 {
			var count = glovoViews.count
			
			if circumference.degrees < 360 && count > 1 {
				count -= 1
			}
			
			spacingDegrees = Angle(degrees: circumference.degrees / Double(count))
		}
	}
}

// MARK: - Actions

extension RadialMenu {
	@objc
	func handlePan(sender: UIPanGestureRecognizer) {
		let location = sender.location(in: self)
		
		switch sender.state {
		case .began:
			guard let item = sender.view else { return }
			attachment = UIAttachmentBehavior(item: item, attachedToAnchor: .zero)
			attachment.anchorPoint = location
			dynamicAnimator.addBehavior(attachment)
			dynamicAnimator.removeBehavior(collision)
		case .changed:
			attachment.anchorPoint = location
		default:
			dynamicAnimator.addBehavior(collision)
			dynamicAnimator.removeBehavior(attachment)
			break
		}
	}
	
	@objc
	func didTapView(sender: UITapGestureRecognizer){
		guard let view = sender.view as? GlovoView else { return }
		didPressButton?(view)
	}
}

// MARK: - Angle

private struct Angle {
	var degrees: Double
	
	func radians() -> Double {
		return degrees * (Double.pi / 180)
	}
}
