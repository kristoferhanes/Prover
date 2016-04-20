//
//  ViewController.swift
//  Prover
//
//  Created by Kristofer Hanes on 2015 11 15.
//  Copyright © 2015 Kristofer Hanes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var textView: UITextView!

  override func viewDidLoad() {
    super.viewDidLoad()
    textView.inputView = UIView()
    textView.inputAssistantItem.leadingBarButtonGroups = []
    textView.inputAssistantItem.trailingBarButtonGroups = []
    textView.becomeFirstResponder()
  }

  @IBAction func didTypeCharacter(sender: UIButton) {
    guard let s = sender.currentTitle else { return }
    textView.insertText(s)
  }

  @IBAction func didPressEvalButton() {
    let props = textView.text.characters.split("\n").flatMap { Prop(string: String($0)) }
    guard !props.isEmpty else { return }
    let premises = [Prop](props.dropLast())
    let conclusion = props.last!
    let isValid = Argument(premises: premises, conclusion: conclusion).isValid
    showAlert(isValid)
  }

  private func showAlert(isValid: Bool) {
    let title = isValid ? "Valid" : "Invalid"
    let message = isValid ? "The argument is valid." : "The argument is invalid."
    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
  }

  @IBAction func didPressReturnButton() {
    textView.insertText("\n")
  }

  @IBAction func didPressBackspaceButton() {
    textView.deleteBackward()
  }
  
}
