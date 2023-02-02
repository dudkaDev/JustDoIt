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
        fetchedResultsController.delegate = self
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

    private var fetchedResultsController = StorageManager.shared.getFetcherResultsController(
        entityName: "Task",
        keyForSort: "date"
    )
    
    private func fetchTasks() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
}

//MARK: - Table View Data Source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        guard let task = fetchedResultsController.object(at: indexPath) as? Task else { return cell }
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
            if let task = self.fetchedResultsController.object(at: indexPath) as? Task {
                StorageManager.shared.delete(task: task)
            }
        }
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
