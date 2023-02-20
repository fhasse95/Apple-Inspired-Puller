//
//  MainViewController.swift
//  PullerLikeAt
//
//  Created by Sergey Zapuhlyak on 14.02.2023.
//

import UIKit

class MainViewController: UIViewController {

    lazy var tableView = UITableView()
    
    private var dataSource: [Section] = []
    
    override func viewDidLoad() {

        super.viewDidLoad()
        setupDataSource()
        setupTableView()
    }
    
    private func setupDataSource() {
        dataSource = []

        if #available(iOS 15.0, *) {
            let appleSection = Section(name: "By Apple", items: makeAppleItems())
            dataSource.append(appleSection)
        }
        
        let sergeySection = Section(name: "By Sergey", items: makeSergeyItems())
        dataSource.append(sergeySection)
    }
    
    private func makeAppleItems() -> [Item] {
        var items: [Item] = []
        
        if #available(iOS 16.0, *) {
            items += [.apple(name: "Small", detents: [.custom(0.25)])]
        }
        
        items += [
            .apple(name: "Medium", detents: [.medium]),
            .apple(name: "Large", detents: [.large])
        ]
        
        if #available(iOS 16.0, *) {
            items += [.apple(name: "Small, Medium, Large", detents: [.custom(0.25), .medium, .large])]
        } else {
            items += [.apple(name: "Medium, Large", detents: [.medium, .large])]
        }
        
        items += [
            .apple(name: "Medium, Large + Refresh Control", detents: [.medium, .large], hasRefreshControl: true),
        ]
        return items
    }
    
    private func makeSergeyItems() -> [Item] {
        [
            .custom(name: "Small", detents: [.custom(0.25)]),
            .custom(name: "Medium", detents: [.medium]),
            .custom(name: "AirPods Pro", detents: [.medium], hasDynamicHeight: false),
            .custom(name: "Large", detents: [.large]),
            .custom(name: "Full", detents: [.full]),
            .custom(name: "Small, Medium, Large", detents: [.custom(0.25), .medium, .large]),
            .custom(name: "Small, Medium, Full", detents: [.custom(0.25), .medium, .full]),
            .custom(name: "Small, Medium, Large, Full", detents: [.custom(0.25), .medium, .large, .full]),
            .custom(name: "Medium, Large + Refresh Control", detents: [.medium, .large], hasRefreshControl: true),
            .custom(name: "Medium, Full + Refresh Control", detents: [.medium, .full], hasRefreshControl: true)
        ]
    }
    
    private func setupTableView() {
        
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = .secondarySystemBackground
        } else {
            tableView.backgroundColor = .white
        }
        view.addSubview(tableView)
        tableView.pin(to: view)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func selectRowAt(_ indexPath: IndexPath) {
        
        let pullerItem = dataSource[indexPath.section].items[indexPath.row]
        
        let someViewController = SomeViewController()
        someViewController.onSelectItem = { [weak self] viewController, item in
            self?.itemDidSelectInPuller(item, byApple: pullerItem.byApple, viewController: viewController)
        }
        someViewController.setBackgroundColor(pullerItem.byApple)
        
        if pullerItem.hasRefreshControl {
            someViewController.addPullToRefresh()
        }
        if !pullerItem.hasDynamicHeight {
            someViewController.addAirPodsPro()
        }
        
        let presentationSettings = PresentationSettings.sharedInstance
        var pullerModel = presentationSettings.makePullerModel(detents: pullerItem.detents, hasDynamicHeight: pullerItem.hasDynamicHeight)
        pullerModel.onChangeDetent = { detent in
            print("change to \(detent)")
        }
        pullerModel.onWillDismiss = {
            print("puller will be closed")
        }
        pullerModel.onDidDismiss = {
            print("puller was closed")
        }
        
        if case .none = pullerModel.dragIndicator {
            someViewController.addHeader()
        }
        
        if #available(iOS 15.0, *), pullerItem.byApple {
            
            presentAsAppleSheet(someViewController, model: pullerModel)
            
        } else {

            presentAsPuller(someViewController, model: pullerModel)
        }
    }
    
    private func itemDidSelectInPuller(_ item: SomeViewController.Item,
                                       byApple: Bool,
                                       viewController: UIViewController) {
        
        if PresentationSettings.sharedInstance.dismissWhenSelectedARow {
            viewController.dismiss(animated: true)
            return
        }
        
        if #available(iOS 15.0, *), byApple, let sheetController = viewController.sheetPresentationController {
            
            sheetController.animateChanges {
                sheetController.selectedDetentIdentifier = .medium
            }
            
        } else if let pullerController = viewController.pullerPresentationController {
            
            pullerController.animateChanges {
                pullerController.selectedDetent = .medium
            }
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        guard let settingsViewController = storyboard?.instantiateViewController(withIdentifier: "settings") as? SettingsViewController else {
            return
        }
        
        let presentationSettings = PresentationSettings.sharedInstance
        presentAsPuller(settingsViewController, model: presentationSettings.makePullerModel(isSettings: true))
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        selectRowAt(indexPath)
    }
}

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataSource[section].name
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            configureCell(cell, at: indexPath)
            return cell
        }

        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        configureCell(cell, at: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        cell.textLabel?.text = dataSource[indexPath.section].items[indexPath.row].name
        
        if #available(iOS 13.0, *) {
            cell.backgroundColor = .secondarySystemBackground
        } else {
            cell.backgroundColor = .white
        }
    }
}

extension MainViewController {
    
    struct Section {
        let name: String
        let items: [Item]
    }
    
    struct Item {
        let name: String
        let byApple: Bool
        let detents: [PullerModel.Detent]
        let hasRefreshControl: Bool
        let hasDynamicHeight: Bool
        
        static func apple(name: String,
                          detents: [PullerModel.Detent],
                          hasRefreshControl: Bool = false,
                          hasDynamicHeight: Bool = true) -> Item {
            Item(name: name,
                 byApple: true,
                 detents: detents,
                 hasRefreshControl: hasRefreshControl,
                 hasDynamicHeight: hasDynamicHeight)
        }
        
        static func custom(name: String,
                           detents: [PullerModel.Detent],
                           hasRefreshControl: Bool = false,
                           hasDynamicHeight: Bool = true) -> Item {
            Item(name: name,
                 byApple: false,
                 detents: detents,
                 hasRefreshControl: hasRefreshControl,
                 hasDynamicHeight: hasDynamicHeight)
        }
    }
}
