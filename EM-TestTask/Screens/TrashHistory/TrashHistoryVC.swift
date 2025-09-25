//
//  TrashHistoryVC.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 24.09.2025.
//

import UIKit

final class TrashHistoryViewController: UIViewController, TrashHistoryViewProtocol {
    var presenter: TrashHistoryPresenterProtocol!
    var tasks: [Task] = [] {
        didSet {
            taskCountLabel.text = "\(tasks.count) \(Formatter.format(tasks.count))"
        }
    }
    var filteredTasks: [Task] = []
    var tasksSections: [TaskSection] = []
    
    private let trashTableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    private let bottomBar = UIToolbar()
    private let taskCountLabel = UILabel()
    private let searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    private lazy var monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.setLocalizedDateFormatFromTemplate("MMMM")
        return f
    }()
    
    private lazy var monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.surfacePrimary
        presenter.viewLoaded()
        configureUI()
    }
    
    func showDeletedTasks(_ tasks: [Task]) {
        self.tasks = tasks
        self.tasksSections = buildSections(from: self.tasks)
        trashTableView.reloadData()
    }
    
    func removeTaskFromScreen(_ task: Task) {
        guard let section = tasksSections.firstIndex(where: { $0.items.contains(where: { $0.id == task.id }) }) else { return }
        guard let row = tasksSections[section].items.firstIndex(where: { $0.id == task.id }) else { return }
        let indexPath = IndexPath(row: row, section: section)
        
        tasks.remove(at: indexPath.row)
        tasksSections[indexPath.section].items.remove(at: indexPath.row)
        trashTableView.deleteRows(at: [indexPath], with: .automatic)
        
        let items = tasksSections[indexPath.section].items
        if items.isEmpty {
            tasksSections.remove(at: indexPath.section)
            trashTableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
    
    func handleTrashTaskCreatedEvent(_ task: Task) {
        debugPrint("Received deleted task: \(task.id)\n\(task.todo)/\(String(describing: task.description))")
        self.tasks.append(task)
        self.tasksSections = buildSections(from: self.tasks)
        trashTableView.reloadData()
    }
    
    
    private func configureUI() {
        configureTitle()
        configureTrashTableView()
        configureSearchController()
        configureBottomBar()
        configureTaskCountLabel()
    }
    
    private func configureTitle() {
        navigationItem.title = "Trash"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func configureTrashTableView() {
        view.addSubview(trashTableView)
        trashTableView.backgroundColor = Colors.surfacePrimary
        trashTableView.separatorStyle = .singleLine
        trashTableView.dataSource = self
        trashTableView.delegate = self
        trashTableView.register(TrashCell.self, forCellReuseIdentifier: "TrashCell")
        trashTableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "SectionHeaderView")
        trashTableView.frame = view.bounds
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.searchTextField.textColor = Colors.textPrimary
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        filteredTasks = tasks
    }
    
    private func configureBottomBar() {
        view.addSubview(bottomBar)
        bottomBar.isTranslucent = true
        bottomBar.barStyle = .black
        
        bottomBar.pinHorizontal(view)
        bottomBar.pinBottom(view.safeAreaLayoutGuide.bottomAnchor, 0)
    }
    
    private func configureTaskCountLabel() {
        taskCountLabel.text = "\(tasks.count) \(Formatter.format(tasks.count))"
        taskCountLabel.font = .systemFont(ofSize: 11, weight: .regular)
        taskCountLabel.textColor = .secondaryLabel
        let centerItem = UIBarButtonItem(customView: taskCountLabel)
        
        bottomBar.setItems([
            .flexibleSpace(),
            centerItem,
            .flexibleSpace()
        ], animated: false)
    }
    
    private func buildSections(from tasks: [Task]) -> [TaskSection] {
        let dated = tasks.compactMap { t -> (Date, Task)? in
            guard let d = t.createdAt else { return nil }
            return (d, t)
        }
        let cal = Calendar.current
        let grouped = Dictionary(grouping: dated, by: { (pair) -> Date in
            let d = pair.0
            let comps = cal.dateComponents([.year, .month], from: d)
            return cal.date(from: comps)!
        })
        let sections: [TaskSection] = grouped.map { (monthStart, pairs) in
            let header: String = {
                let year = cal.component(.year, from: monthStart)
                let thisYear = cal.component(.year, from: Date())
                if year == thisYear {
                    return monthFormatter.string(from: monthStart)
                } else {
                    return monthYearFormatter.string(from: monthStart)
                }
            }()
            let items = pairs
                .sorted { $0.0 > $1.0 }
                .map { $0.1 }
            
            return TaskSection(header: header, items: items)
        }
            .sorted { $0.items.first?.createdAt ?? .distantPast > $1.items.first?.createdAt ?? .distantPast }
        return sections
    }
}

extension TrashHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasksSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredTasks.count : tasks.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeaderView") as? SectionHeaderView else {
            return UIView()
        }
        if !searchController.isActive {
            header.label.text = tasksSections[section].header
            return header
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrashCell", for: indexPath) as? TrashCell else {
            return UITableViewCell()
        }
        let item = tasksSections[indexPath.section].items[indexPath.row]
        cell.configure(item)
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = tasksSections[indexPath.section].items[indexPath.row]
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: {
            
            let vc = TaskAssembly.build(task)
            vc.view.backgroundColor = Colors.surfacePrimary
            vc.overrideUserInterfaceStyle = .dark
            return vc
            
        }, actionProvider: { _ in
            let restoreAction = UIAction(title: "Восстановить", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.tasks.remove(at: indexPath.row)
                self?.tasksSections[indexPath.section].items.remove(at: indexPath.row)
                self?.trashTableView.deleteRows(at: [indexPath], with: .automatic)
                
                if let items = self?.tasksSections[indexPath.section].items {
                    if items.isEmpty {
                        self?.tasksSections.remove(at: indexPath.section)
                        self?.trashTableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    }
                }
                
                self?.presenter.restorePressed(task)
            }
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.presenter.deletePressed(task)
                self?.tasks.remove(at: indexPath.row)
                self?.tasksSections[indexPath.section].items.remove(at: indexPath.row)
                self?.trashTableView.deleteRows(at: [indexPath], with: .automatic)
                
                if let items = self?.tasksSections[indexPath.section].items {
                    if items.isEmpty {
                        self?.tasksSections.remove(at: indexPath.section)
                        self?.trashTableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                    }
                }
            }
            
            return UIMenu(title: "", children: [restoreAction, deleteAction])
        })
        return configuration
    }
}

extension TrashHistoryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            filteredTasks = tasks
            trashTableView.reloadData()
            return
        }

        let lower = query.lowercased()
        filteredTasks = tasks.filter { task in
            task.todo.lowercased().contains(lower)
        }

        trashTableView.reloadData()
    }
}
