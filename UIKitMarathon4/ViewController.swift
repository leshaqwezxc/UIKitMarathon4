//
//  ViewController.swift
//  UIKitMarathon4
//
//  Created by alexeituszowski on 10.09.2023.
//

import UIKit

class ViewController: UIViewController {
    
    struct TableCellItem: Hashable {
        static func == (lhs: ViewController.TableCellItem, rhs: ViewController.TableCellItem) -> Bool {
            lhs.value == rhs.value
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(value)
        }
        
        let value: Int
        var isSelected: Bool
    }
    
    enum Section {
        case main
    }
    
    var data: [TableCellItem] = {
        var data: [TableCellItem] = []
        for i in 0...30 {
            data.append(TableCellItem(value: i, isSelected: false))
        }

        return data
    }()

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    lazy var dataSource = UITableViewDiffableDataSource<Section, TableCellItem>(tableView: tableView) { tableView, indexPath, itemIdentifier in
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(itemIdentifier.value)"
        if itemIdentifier.isSelected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        view.backgroundColor = .white
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, TableCellItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource.apply(snapshot)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .done, target: self, action: #selector(shuffle))
    }
    
    @objc
    private func shuffle() {
        data = data.shuffled()
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, TableCellItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource.apply(snapshot)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard var item = dataSource.itemIdentifier(for: indexPath) else { return }
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
        if let index = data.firstIndex(of: item) {
            data.remove(at: index)
            item.isSelected.toggle()
            if !item.isSelected {
                return 
            }
            data.insert(item, at: 0)
            var snapshot = NSDiffableDataSourceSnapshot<Section, TableCellItem>()
            snapshot.appendSections([.main])
            snapshot.appendItems(data)
            dataSource.apply(snapshot)
        }
    }
}

