//
//  Cell.swift
//  Formulary
//
//  Created by Fabian Canas on 1/16/15.
//  Copyright (c) 2015 Fabian Canas. All rights reserved.
//

import UIKit

public enum FormRowType: String {
    case Plain   = "Plain"
    case Switch  = "Switch"
    case Text    = "Text"
    case Number  = "Number"
    case Decimal = "Decimal"
}

extension UITableView {
    func registerFormCellClasses() {
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: FormRowType.Plain.rawValue)
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: FormRowType.Switch.rawValue)
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: FormRowType.Text.rawValue)
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: FormRowType.Number.rawValue)
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: FormRowType.Decimal.rawValue)
    }
}

func configureCell(cell: UITableViewCell, inout row: FormRow) {
    
    switch row.type {
    case .Plain:
        cell.textLabel?.text = row.name
        break
    case .Switch:
        cell.textLabel?.text = row.name
        let s = UISwitch()
        cell.accessoryView = s
        ActionTarget(control: s, action: { _ in
            row.value = s.on
        })
        
        if let enabled = row.value as? Bool {
            s.on = enabled
        }
    case .Text:
        configureTextCell(cell, &row).keyboardType = .Default
    case .Number:
        configureTextCell(cell, &row).keyboardType = .NumberPad
    case .Decimal:
        configureTextCell(cell, &row).keyboardType = .DecimalPad
    }
    cell.selectionStyle = .None
}

func configureTextCell(cell: UITableViewCell, inout row: FormRow) -> UITextField {
    let textField = NamedTextField(frame: cell.contentView.bounds)
    textField.setTranslatesAutoresizingMaskIntoConstraints(false)
    textField.text = row.value as? String
    textField.placeholder = row.name
    
    cell.contentView.addSubview(textField)
    
    cell.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[textField]-|", options: nil, metrics: nil, views: ["textField":textField]))
    
    ActionTarget(control: textField, controlEvents: .EditingChanged, action: { _ in
        row.value = textField.text
    })
    return textField
}

let ActionTargetControlKey :UnsafePointer<Void> = UnsafePointer<Void>()

class ActionTarget {
    let control: UIControl
    let closure: (UIControl) -> Void
    init(control: UIControl, controlEvents: UIControlEvents = .ValueChanged, action: (AnyObject?) -> Void) {
        self.control = control
        closure = action
        control.addTarget(self, action: Selector("action:"), forControlEvents: controlEvents)
        
        objc_setAssociatedObject(control, ActionTargetControlKey, self, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }
    
    @objc func action(sender: UIControl) {
        closure(sender)
    }
}
    
