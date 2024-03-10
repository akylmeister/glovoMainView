//  Created by Akyl Temirgaliyev on 09.03.2024.

import UIKit

final class ViewController: UIViewController {
	
	let items = [
		GlovoItem(image: .init(named: "samokat") ?? UIImage(), text: "Самокаты"),
		GlovoItem(image: .init(named: "delivery") ?? UIImage(), text: "Доставка"),
		GlovoItem(image: .init(named: "poputka") ?? UIImage(), text: "Попутка"),
		GlovoItem(image: .init(named: "bonuses") ?? UIImage(), text: "Бонусы"),
		GlovoItem(image: .init(named: "transport") ?? UIImage(), text: "Транспорт"),
	]
	
	// MARK: - Private Properties
	
	private lazy var wheelView: RadialMenu = {
		let view = RadialMenu(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		
		return view
	}()
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupView()
		wheelView.generateButtons(
			items: items,
			centerItem: GlovoItem(image: .init(named: "car") ?? UIImage(), text: "Такси")
		)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		wheelView.presentInView()
	}
	
	// MARK: - Private Methods
	
	private func setupView() {
		view.backgroundColor = UIColor(red: 245/255, green: 244/255, blue: 255/255, alpha: 1)
		
		view.addSubview(wheelView)
		NSLayoutConstraint.activate([
			wheelView.heightAnchor.constraint(equalToConstant: 500),
			wheelView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
			wheelView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
			wheelView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
		])
	}
}
