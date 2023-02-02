//
//  TaskListViewController.swift
//  JustDoIt
//
//  Created by Андрей Абакумов on 01.02.2023.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTasks()
        getFetchedResultsController.delegate = self
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        let fontName = "Apple SD Gothic Neo Bold"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.titleTextAttributes = [
            .font: UIFont(name: fontName, size: 19) ?? UIFont.systemFont(ofSize: 19),
            .foregroundColor: UIColor.white
        ]
        
        navBarAppearance.largeTitleTextAttributes = [
            .font: UIFont(name: fontName, size: 35) ?? UIFont.systemFont(ofSize: 35),
            .foregroundColor: UIColor.white
        ]
        navBarAppearance.backgroundColor = UIColor(
            red: 97/255,
            green: 210/255,
            blue: 255/255,
            alpha: 255/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }

    private var getFetchedResultsController = StorageManager.shared.fetchedResultsController(
        entityName: "Task",
        keyForSort: ["isComplete", "date"]
    )
    
    private func fetchTasks() {
        do {
            try getFetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
}

//MARK: - Table View Data Source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        getFetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        guard let task = getFetchedResultsController.object(at: indexPath) as? Task else { return cell }
        cell.contentConfiguration = setContentForCell(with: task)
        return cell
    }
    
    private func setContentForCell(with task: Task?) -> UIListContentConfiguration {
        var content = UIListContentConfiguration.cell()
        
        content.textProperties.font = UIFont(
            name: "Avenir Next Medium",
            size: 23
        ) ?? UIFont.systemFont(ofSize: 23)
        
        content.textProperties.color = .darkGray
        content.text = task?.title
        content.attributedText = strikeThrough(string: task?.title ?? "", task?.isComplete ?? false)
        
        return content
    }
}

//MARK: - NSFetchResultsControllerDelegate
extension TaskListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

//MARK: - Table View Delegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            if let task = self.getFetchedResultsController.object(at: indexPath) as? Task {
                StorageManager.shared.delete(task: task)
            }
        }
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = getFetchedResultsController.object(at: indexPath) as? Task
        performSegue(withIdentifier: "editTask", sender: task)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTask" {
            guard let newTaskVC = segue.destination as? NewTaskViewController else { return }
            newTaskVC.task = sender as? Task
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
            if let task = self.getFetchedResultsController.object(at: indexPath) as? Task {
                StorageManager.shared.done(task: task)
            }
            isDone(true)
        }
        doneAction.image = UIImage(systemName: "checkmark")
        doneAction.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction])
    }
    
    private func strikeThrough(string: String, _ isStrikeThrough: Bool) -> NSAttributedString {
        isStrikeThrough
        ? NSAttributedString(
            string: string,
            attributes: [NSAttributedString.Key.strikethroughStyle : NSUnderlineStyle.double.rawValue]
        )
        : NSAttributedString(
            string: string,
            attributes: [NSAttributedString.Key.strikethroughStyle : 0]
        )
    }
}
