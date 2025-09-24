//
//  TaskVC.swift
//  EM-TestTask
//
//  Created by Кирилл Исаев on 23.09.2025.
//

import UIKit

final class TaskViewController: UIViewController {
    
    var presenter: TaskPresenterProtocol!
    
    private let todoTextField: UITextField = UITextField()
    private let dateLabel: UILabel = UILabel()
    private let descriptionTextField: UITextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        presenter.viewLoaded()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setFocusOn(todoTextField)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if checkFields() {
            let task = getTask()
            presenter.saveButtonPressed(task)
        }
    }
    
    func showTask(_ task: Task) {
        todoTextField.text = task.todo
        descriptionTextField.text = task.description
        dateLabel.text = "Created at: \(String(describing: task.createdAt?.description))"
    }
    
    private func configureUI() {
        configureTodoTextField()
        configureDateLabel()
        configureDescriptionTextField()
    }
    
    private func configureTodoTextField() {
        view.addSubview(todoTextField)
        todoTextField.delegate = self
        todoTextField.textColor = Colors.textPrimary
        todoTextField.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        todoTextField.tintColor = Colors.textPrimary
        todoTextField.minimumFontSize = 14
        todoTextField.placeholder = ""
        todoTextField.autocorrectionType = .no
        todoTextField.autocapitalizationType = .none
        todoTextField.textAlignment = .left
        todoTextField.adjustsFontSizeToFitWidth = true
        todoTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        todoTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        todoTextField.pinHorizontal(view, 16)
        todoTextField.pinTop(view.safeAreaLayoutGuide.topAnchor, 12)
    }
    
    private func configureDateLabel() {
        view.addSubview(dateLabel)
        let now = Date()
        dateLabel.text = "Created at: \(Calendar.current.date(byAdding: .hour, value: 3, to: now) ?? Date())"
        dateLabel.font = Fonts.dateFont
        dateLabel.textColor = Colors.textSecondary
        
        
        dateLabel.pinTop(todoTextField.bottomAnchor, 12)
        dateLabel.pinLeft(view.safeAreaLayoutGuide.leadingAnchor, 12)
        
    }
    
    private func configureDescriptionTextField() {
        view.addSubview(descriptionTextField)
        descriptionTextField.font = Fonts.titleFont
        descriptionTextField.textColor = Colors.textPrimary
        descriptionTextField.tintColor = Colors.textPrimary
        descriptionTextField.autocorrectionType = .no
        descriptionTextField.autocapitalizationType = .none
        descriptionTextField.textAlignment = .left
        descriptionTextField.backgroundColor = .clear
        
        descriptionTextField.pinTop(dateLabel.bottomAnchor, 16)
        descriptionTextField.pinHorizontal(view, 16)
        descriptionTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 250).isActive = true
    }
    
    private func checkFields() -> Bool {
        guard let text = todoTextField.text else { return false }
        return !text.isEmpty
    }
    
    private func getTask() -> TaskCreateDTO {
        if let todo = todoTextField.text {
            return TaskCreateDTO(
                todo: todo,
                description: descriptionTextField.text
            )
        }
        return TaskCreateDTO(todo: "Default", description: nil)
    }
    
    private func setFocusOn(_ view: UIView) {
        view.becomeFirstResponder()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension TaskViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cur = textField.text ?? ""
        guard let ran = Range(range, in: cur) else { return false }
        let updated = cur.replacingCharacters(in: ran, with: string)
        textField.adjustsFontSizeToFitWidth = !updated.isEmpty && updated.count > 10
        return updated.count <= 32
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if todoTextField.isFirstResponder {
            if let text = todoTextField.text {
                if !text.isEmpty {
                    setFocusOn(descriptionTextField)
                }
            }
        }
        return true
    }
}
