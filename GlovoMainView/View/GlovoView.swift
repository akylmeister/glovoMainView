//
//  GlovoView.swift
//  GlovoMainView
//
//  Created by Akyl Temirgaliyev on 09.03.2024.
//

import Foundation
import UIKit

final class GlovoView: UIView {
	
	var glovoItem: GlovoItem?
	public var originalCenter : CGPoint = .zero
	weak var attachementBehavior:UIAttachmentBehavior!
	
	private lazy var itemImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		
		return imageView
	}()
	
	private lazy var itemLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = .black
		label.lineBreakMode = .byWordWrapping
		label.textAlignment = .center
		label.numberOfLines = 2
		label.adjustsFontSizeToFitWidth = true
		
		return label
	}()
	
	public override var collisionBoundsType: UIDynamicItemCollisionBoundsType { return .path }
	
	public override var collisionBoundingPath: UIBezierPath { return circularPath() }
	
	// MARK: - Init
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupView()
		setupShadow()
	}
	
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	func configure(with item: GlovoItem) {
		glovoItem = item
		itemLabel.text = item.text
		itemImageView.image = item.image
	}
	
	// MARK: - Private Methods
	
	private func setupView() {
		isUserInteractionEnabled = true
		layer.cornerRadius = frame.width / 2
		backgroundColor = .white
		
		addSubview(itemImageView)
		addSubview(itemLabel)
		
		let heightConstraint = itemImageView.heightAnchor.constraint(equalToConstant: frame.size.height / 2)
		heightConstraint.priority = .init(999)
		heightConstraint.isActive = true
		
		NSLayoutConstraint.activate([
			itemImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
			itemImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
			itemImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
			
			itemLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
			itemLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
			itemLabel.topAnchor.constraint(equalTo: itemImageView.bottomAnchor, constant: 5),
			itemLabel.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -30)
		])
	}
	
	private func setupShadow() {
		layer.masksToBounds = false
		layer.shadowOffset = CGSize(width: 0, height: 1)
		layer.shadowOpacity = 0.3
		layer.shadowRadius = 3
		layer.shadowColor = UIColor.black.cgColor
	}
	
	private func circularPath() -> UIBezierPath {
		let radius = frame.size.width / 2
		return UIBezierPath(arcCenter: .zero, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
	}
}
