//
//  NewTaskViewController.swift
//  JustDoIt
//
//  Created by Андрей Абакумов on 01.02.2023.
//

import UIKit

class NewTaskViewController: UIViewController {
    
    @IBOutlet var taskTextView: UITextView!
    @IBOutlet var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.isHidden = true
        
    }
    
    @IBAction func doneButtonPressed() {
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonPressed() {
        dismiss(animated: true)
    }
}
