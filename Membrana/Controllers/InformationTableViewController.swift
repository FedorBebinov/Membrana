//
//  InformationTableViewController.swift
//  Membrana
//
//  Created by Fedor Bebinov on 13.04.23.
//

import UIKit

class InformationTableViewController: UITableViewController {
    
    let gesturesDescription = [
        0: "Aктивируется одиночным тапом по экрану. Основной жест, символизирующий желание дотронуться до собеседника, почувствовать  его сквозь \"тонкую ткань\" экрана.",
        1: "Aктивируется двойным тапом. Показывает хорошее настроение, настрой на позитивный лад.",
        2: "Aктивируется проведением по экрану сверну вниз. Демонстрирует резкое проявление эмоций, бурную реакцию на какое-либо событие.",
        3: "Aктивируется при проведении на экране круга. Символизирует легкую печаль, меланхоличное настроение."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Table view data source
    private func setupView() {
        view.backgroundColor = Colors.gray_23
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = Colors.gray_23
            headerView.textLabel?.textColor = .white
            headerView.textLabel?.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            headerView.textLabel?.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        
        switch section {
        case 0:
            sectionName = "Касание"
        case 1:
            sectionName = "Свет"
        case 2:
            sectionName = "Гром"
        case 3:
            sectionName = "Дождь"
        default:
            sectionName = "Касание"
        }
        return sectionName
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = gesturesDescription[indexPath.section]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .white
        cell.contentView.backgroundColor = Colors.gray_23
        return cell
    }
}
