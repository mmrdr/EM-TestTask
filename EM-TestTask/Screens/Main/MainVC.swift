//
//  MainVC.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import UIKit

final class MainViewController: UIViewController, MainViewProtocol  {
    var presenter: MainPresenterProtocol!
    var tasks: [Task] = [
        Task(id: 1, todo: "Do math and swift", description: "No description provided", completed: false, userId: 1, createdAt: Date.now),
        Task(id: 2, todo: "GYM", description: "Do pull ups and bench press. Maybe run after this", completed: false, userId: 1, createdAt: Date.now)
    ]
    
    private let searchController: UISearchController = UISearchController()
    private let tasksTableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    private let bottomBar = UIToolbar()
    private let taskCountLabel = UILabel()
    private var addItemButton: UIBarButtonItem = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Protocol Methods
    
    func showError(_ error: String) {
        let alertController = UIAlertController(title: "Ooops, error", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(ok)
        self.present(alertController, animated: true)
    }
    
    func showTasks(_ tasks: [Task]) {
        self.tasks = tasks
    }
    
    func startLoadingAnimation() {
        //
    }
    
    func stopLoadingAnimation() {
        //
    }
    
    // MARK: - UI
    
    private func configureUI() {
        configureTitle()
        configureSearchController()
        configureTasksTableView()
        configureBottomBar()
        configureAddTaskButton()
        configureTaskCountLabel()
    }
    
    private func configureTitle() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "Задачи"
        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.standardAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    
    private func configureSearchController() {
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.searchTextField.textColor = Colors.textPrimary
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureTasksTableView() {
        view.addSubview(tasksTableView)
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tasksTableView.backgroundColor = Colors.surfacePrimary
        
        tasksTableView.pinHorizontal(view)
        tasksTableView.pinTop(view.topAnchor, 0)
        tasksTableView.pinBottom(view.bottomAnchor, 0)
    }
    
    private func configureBottomBar() {
        view.addSubview(bottomBar)
        bottomBar.isTranslucent = true
        bottomBar.barStyle = .black
        
        bottomBar.pinHorizontal(view)
        bottomBar.pinBottom(view.safeAreaLayoutGuide.bottomAnchor, 0)
    }
    
    private func configureAddTaskButton() {
        addItemButton = UIBarButtonItem(systemItem: .compose, primaryAction: UIAction { [weak self] _ in
             self?.createTask()
         })
        addItemButton.tintColor = Colors.checkSecondary
    }
    
    private func configureTaskCountLabel() {
        taskCountLabel.text = "\(tasks.count) Задач"
        taskCountLabel.font = .systemFont(ofSize: 11, weight: .regular)
        taskCountLabel.textColor = .secondaryLabel
        let centerItem = UIBarButtonItem(customView: taskCountLabel)
        
        bottomBar.setItems([
            .flexibleSpace(),
            centerItem,
            .flexibleSpace(),
            addItemButton
        ], animated: false)
    }
    
    private func createTask() {
        
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        let item = tasks[indexPath.row]
        cell.configure(item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasks[indexPath.row].completed.toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = tasks[indexPath.row]
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.presenter.updateTaskPressed(task)
            }
            
            let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
                self?.presenter.shareTaskPressed(task)
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.presenter.deleteTaskPressed(task)
            }
            
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
        return configuration
    }
}

extension MainViewController: UISearchControllerDelegate {
    
}
