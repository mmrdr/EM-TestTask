//
//  MainVC.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import UIKit

final class MainViewController: UIViewController, MainViewProtocol  {
    var presenter: MainPresenterProtocol!
    var tasks: [Task] = [] {
        didSet {
            taskCountLabel.text = "\(tasks.count) \(Formatter.format(tasks.count))"
        }
    }
    var filteredTasks: [Task] = []
    var failedTaskIDs = Set<Int64>() // для хранения зафейленных айди, решение проблемы с переиспользованием ячеек
    
    private let searchController: UISearchController = UISearchController(searchResultsController: nil)
    private let tasksTableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    private let bottomBar = UIToolbar()
    private let taskCountLabel = UILabel()
    private var addItemButton: UIBarButtonItem = UIBarButtonItem()
    private var trashItemButton: UIBarButtonItem = UIBarButtonItem()
    private let loader = LoadingRingsView()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotifications()
        presenter.viewLoaded()
        loader.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(loader)
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loader.widthAnchor.constraint(equalToConstant: 40),
            loader.heightAnchor.constraint(equalTo: loader.widthAnchor)
        ])
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureTitle()
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
        tasksTableView.reloadData()
    }
    
    func appendTasks(_ newTasks: [Task]) {
        guard !newTasks.isEmpty else { return }

        let startIndex = tasks.count
        let endIndex = startIndex + newTasks.count - 1
        let indexPaths = (startIndex...endIndex).map { IndexPath(row: $0, section: 0) }

        self.tasks.append(contentsOf: newTasks)

        if #available(iOS 11.0, *) {
            tasksTableView.performBatchUpdates({
                tasksTableView.insertRows(at: indexPaths, with: .automatic)
            }, completion: nil)
        } else {
            tasksTableView.beginUpdates()
            tasksTableView.insertRows(at: indexPaths, with: .automatic)
            tasksTableView.endUpdates()
        }
    }
    
    func startLoadingAnimation() {
        loader.start()
    }
    
    func stopLoadingAnimation() {
        loader.stop()
    }
    
    func handleStartAnimation(_ taskId: Int64) {
        if let index = tasks.firstIndex(where: {$0.id == taskId}) {
            if let cell = tasksTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TaskCell {
                cell.startAnimation()
            }
        }
    }
    
    func handleStopAnimation(_ taskId: Int64) {
        if let index = tasks.firstIndex(where: {$0.id == taskId}) {
            if let cell = tasksTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TaskCell {
                cell.stopAnimation()
            }
        }
    }
    
    func handleError(_ taskId: Int64) {
        if let index = tasks.firstIndex(where: {$0.id == taskId}) {
            if let cell = tasksTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TaskCell {
                cell.showError()
                failedTaskIDs.insert(taskId)
                tasksTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    
    func updateTaskId(_ task: Task) {
        if let index = tasks.firstIndex(where: {$0.todo == task.todo && $0.createdAt == $0.createdAt}) {
            tasks[index] = task
        }
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTasksCreatedEvent), name: .tasksCreatedEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTaskUpdatedEvent), name: .taskUpdatedEvent, object: nil)
    }
    
    // MARK: - UI
    
    private func configureUI() {
        configureTitle()
        configureSearchController()
        configureTasksTableView()
        configureBottomBar()
        configureAddTaskButton()
        configureTrashItemButton()
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
    
    private func configureTasksTableView() {
        view.addSubview(tasksTableView)
        view.bringSubviewToFront(loader)
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
    
    private func configureTrashItemButton() {
        trashItemButton = UIBarButtonItem(systemItem: .trash, primaryAction: UIAction { [weak self] _ in
            self?.openTrashHistory()
        })
        trashItemButton.tintColor = .red
    }
    
    private func configureTaskCountLabel() {
        taskCountLabel.text = "\(tasks.count) \(Formatter.format(tasks.count))"
        taskCountLabel.font = .systemFont(ofSize: 11, weight: .regular)
        taskCountLabel.textColor = .secondaryLabel
        let centerItem = UIBarButtonItem(customView: taskCountLabel)
        
        bottomBar.setItems([
            trashItemButton,
            .flexibleSpace(),
            centerItem,
            .flexibleSpace(),
            addItemButton,
            
        ], animated: false)
    }
    
    private func createTask() {
        presenter.createNewTaskPressed()
    }
    
    
    private func openTrashHistory() {
        presenter.openTrashHistory()
    }
    
    private func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: {$0.id == task.id }) {
            tasks[index] = task
            tasksTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            debugPrint("Updated task(id:\(task.id)) on: \(task.todo), \(String(describing: task.description))")
        }
    }
    
    @objc private func handleTasksCreatedEvent(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let task = userInfo["task"] as? Task {
            debugPrint("Received task: \(task.id)\n\(task.todo)\n\(String(describing: task.description))")
            tasks.insert(task, at: 0)
            tasksTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    
    @objc private func handleTaskUpdatedEvent(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let task = userInfo["task"] as? Task {
            updateTask(task)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .tasksCreatedEvent, object: nil)
        NotificationCenter.default.removeObserver(self, name: .taskUpdatedEvent, object: nil)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredTasks.count : tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        let item = tasks[indexPath.row]
        cell.configure(item, failedTaskIDs)
        cell.failButtonTapped = {
            let alertController = UIAlertController(title: "Что делаем с таской?", message: nil, preferredStyle: .alert)
            let tryAgainAction = UIAlertAction(title: "Сохранить заново", style: .default) { [weak self] _ in
                self?.presenter.createTask(item)
            }
            let delete = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                self?.tasks.remove(at: indexPath.row)
                self?.tasksTableView.deleteRows(at: [indexPath], with: .automatic)
                NotificationCenter.default.post(name: .trashTaskCreatedEvent, object: nil, userInfo: ["task": item])
                self?.presenter.deleteTaskPressed(item)
            }
            alertController.addAction(tryAgainAction)
            alertController.addAction(delete)
            self.present(alertController, animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tasksTableView.cellForRow(at: indexPath) as? TaskCell {
            if !cell.isActive {
                cell.selectionStyle = .none
            } else {
                tasks[indexPath.row].completed.toggle()
                presenter.taskCompletedStatusChanged(tasks[indexPath.row])
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = tasks[indexPath.row]
        guard let cell = tasksTableView.cellForRow(at: indexPath) as? TaskCell else { return nil }
        if !cell.isActive { return nil }
        let configuration = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath,
                                                       previewProvider: {
            return TaskAssembly.build(task)
        }, actionProvider: { _ in
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.presenter.updateTaskPressed(task)
            }
            
            let shareAction = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
                self?.presenter.shareTaskPressed(task)
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.tasks.remove(at: indexPath.row)
                self?.tasksTableView.deleteRows(at: [indexPath], with: .automatic)
                NotificationCenter.default.post(name: .trashTaskCreatedEvent, object: nil, userInfo: ["task": task])
                self?.presenter.deleteTaskPressed(task)
            }
            
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        })
        return configuration
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let threshold = max(tasks.count - 5, 0)
        if indexPath.row >= threshold {
            presenter.reachedEnd()
        }
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
        guard let indexPath = configuration.identifier as? NSIndexPath else { return }
        let task = self.tasks[indexPath.row]
        animator.addCompletion { [weak self] in
            self?.presenter.updateTaskPressed(task)
        }
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            filteredTasks = tasks
            tasksTableView.reloadData()
            return
        }

        let lower = query.lowercased()
        filteredTasks = tasks.filter { task in
            task.todo.lowercased().contains(lower)
        }

        tasksTableView.reloadData()
    }
}

class Formatter {
    static func format(_ n: Int) -> String {
        if n % 10 == 0, n % 10 == 5, n % 10 == 6, n % 10 == 7, n % 10 == 8, n % 10 == 9 { return "Задач" }
        else if n % 10 == 1 { return "Задача" }
        else if n % 10 == 2, n % 10 == 3, n % 4 == 0 { return "Задачи" }
        else { return "Задач" }
    }
}
