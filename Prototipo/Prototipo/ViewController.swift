//
//  ViewController.swift
//  Prototipo
//
//  Created by Jean Camargo on 24/05/23.
//

import UIKit

class ViewController: UITableViewController {

	var restaurantItem: [FakeRestaurantViewModel] = []

	override func viewDidLoad() {
		super.viewDidLoad()

		refresh()
	}

	@IBAction func refresh() {
		refreshControl?.beginRefreshing()

		DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
			guard let self, self.restaurantItem.isEmpty else {
				self?.refreshControl?.endRefreshing()

				return
			}

			self.restaurantItem = FakeRestaurantViewModel.dataModel
			self.tableView.reloadData()
			self.refreshControl?.endRefreshing()
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return restaurantItem.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let viewModel = restaurantItem[indexPath.row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantItemCell", for: indexPath) as! RestaurantItemCell

		cell.title.text = viewModel.title
		cell.location.text = viewModel.location
		cell.parasols.text = viewModel.parasols
		cell.collectionOfRating.enumerated().forEach { (index, image) in
			let systemName = index < viewModel.rating ? "star.fill" : "star"

			image.image = UIImage(systemName: systemName)
		}

		return cell
	}
}

final class RestaurantItemCell: UITableViewCell {
	@IBOutlet private(set) var title: UILabel!
	@IBOutlet private(set) var location: UILabel!
	@IBOutlet private(set) var distance: UILabel!
	@IBOutlet private(set) var parasols: UILabel!
	@IBOutlet private(set) var collectionOfRating: [UIImageView]!
}
