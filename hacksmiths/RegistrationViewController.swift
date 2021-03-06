//
//  RegistrationViewController.swift
//  hacksmiths
//
//  Created by Ryan Collins on 4/14/16.
//  Copyright © 2016 Tech Rapport. All rights reserved.
//

import UIKit
import TextFieldEffects
import ChameleonFramework

/** Registration view controller handles the registration process for a user.
 */
class RegistrationViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var fullNameTextField: IsaoTextField!
    @IBOutlet weak var emailTextField: IsaoTextField!
    @IBOutlet weak var passwordTextField: IsaoTextField!
    @IBOutlet weak var debugLabel: UILabel!
    let xInSquareImage = UIImage(named: "x-in-square")
    let backwardArrowImage = UIImage(named: "backward-arrow")
    
    // Mark: Regular expression for email
    static private let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    private var activityIndicator: IGActivityIndicatorView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator = IGActivityIndicatorView(inview: view, messsage: "Registering")
    }
    
    func hideLoading() {
        activityIndicator.startAnimating()
    }
    
    func showLoading() {
        activityIndicator.stopAnimating()
    }
    
    func setupView() {
        setNavigationControllerItems()
        setupViewForNextField()
        debugLabel.alpha = 0.0
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor();
    }
    
    /** Did change the text in a text field, determine if the field is valid and then set the next button enabled when appropriate.
     *
     *  @param sender - the text field that sent the message
     *  @return None
     */
    func didChangeTextInTextField(sender: IsaoTextField) {
        if validateField(RegistrationViewModel.sharedInstance.currentField!, withValue: sender.text) {
            navigationItem.rightBarButtonItem?.enabled = true
        } else {
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    func setNavigationControllerItems() {
        let rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(RegistrationViewController.processSubmission(_:)))
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        
        // Set the right bar button title to Done if we are on the last text field.
        if RegistrationViewModel.sharedInstance.currentField == .Password || RegistrationViewModel.sharedInstance.currentField == .None {
            rightBarButtonItem.title = "Done"
        }
        let itemButtonImage = buttonItemImage(forField: RegistrationViewModel.sharedInstance.currentField!)
        let leftBarButtonItem = UIBarButtonItem(image: itemButtonImage, style: .Plain, target: self, action: #selector(RegistrationViewController.proceedBackwards(_:)))
        leftBarButtonItem.tintColor = UIColor.whiteColor()
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    /** Setup the view for the text field
     *
     *  @param textField - the text field being setup
     *  @return None
     */
    private func setupTextField(textField: IsaoTextField){
        textField.addTarget(self, action: #selector(RegistrationViewController.didChangeTextInTextField), forControlEvents: UIControlEvents.EditingChanged)
        textField.becomeFirstResponder()
        textField.delegate = self
    }

    
    /** Validate the text field, returning false if not valid
     *
     *  @param field - the field being validated
     *  @return Bool - whether the field is valid
     */
    private func validateField(field: RegistrationViewModel.RegistrationField, withValue value: String?) -> Bool {
        guard value != nil else {
            return false
        }
        
        switch field {
        case .FullName:
            return value?.rangeOfString(" ") != nil
        case .Email:
            let emailTest = NSPredicate(format: "SELF MATCHES %@", RegistrationViewController.emailRegEx)
            return emailTest.evaluateWithObject(value!)
        case .Password:
            return value!.length > 8
        default:
            return false
        }
    }
    
    /** Show a debug label when there is an issue
     */
    func showDebugLabel(withText text: String) {
        debugLabel.text = text
        debugLabel.fadeIn(0.5, delay: 0.0, alpha: 1.0, completion: nil)
    }
}

/** Extension for one field form processing in view controller
 */
extension RegistrationViewController {
    /** Responsible for making changes to the UI that rely on the value of the next field
     *
     *  @param None
     *  @return None
     */
    private func setupViewForNextField() {
        if let currentField = RegistrationViewModel.sharedInstance.currentField {
            switch currentField {
            case .FullName:
                self.view.backgroundColor = UIColor.flatSkyBlueColor()
                self.emailTextField.hidden = true
                self.passwordTextField.hidden = true
                self.fullNameTextField.hidden = false
                self.headerLabel.text = "What should we call you?"
                self.setupTextField(self.fullNameTextField)
            case .Email:
                self.view.backgroundColor = UIColor.flatRedColor()
                self.fullNameTextField.hidden = true
                self.passwordTextField.hidden = true
                self.emailTextField.hidden = false
                self.headerLabel.text = "What is your email?"
                self.setupTextField(self.emailTextField)
            case .Password:
                self.view.backgroundColor = UIColor.flatMintColorDark()
                self.fullNameTextField.hidden = true
                self.emailTextField.hidden = true
                self.headerLabel.text = "Set your password."
                self.passwordTextField.hidden = false
                self.setupTextField(self.passwordTextField)
            default:
                break
            }
        }
        
    }
    
    /* Method called by view controller to make logic decisions for how to
     * Submit data and continue with the registration process.
     * Called from the Next button in the view.  Calling other
     * methods (the ones below here) will skip steps and the registration will
     * fail.
     *
     *  @param sender - the sender sending the message
     *  @return None
     */
    func processSubmission(sender: AnyObject) {
        let currentField = RegistrationViewModel.sharedInstance.currentField
        let currentValue = dataValue(forField: currentField!)
        
        if validateField(currentField!, withValue: currentValue) {
            RegistrationViewModel.sharedInstance.didFinishRegistering(withField: currentField!, value: currentValue!)
            proceedOrCompleteRegistration(forField: currentField!)
        } else {
            showDebugLabel(withText: debugMessage(forField: currentField!))
        }
    }
    
    /** Proceed or complete the registration process
     *
     *  @param field - the current registration field being submitted
     *  @return None
     */
    func proceedOrCompleteRegistration(forField field: RegistrationViewModel.RegistrationField){
        switch field {
        case .Password:
            submitRegistration()
        default:
            proceedForwards(self)
        }
    }
    
    /** Proceed forwards in the registration process
     *
     *  @param Sender the sender that sent the message
     *  @return None
     */
    func proceedForwards(sender: AnyObject) {
        let nextViewController = storyboard?.instantiateViewControllerWithIdentifier("RegistrationViewController")
            as! RegistrationViewController
        dispatch_async(GlobalMainQueue, {
            self.navigationController?.pushViewController(nextViewController, animated: true)
        })
        
    }
    
    /** Proceed backwards through the registration process
     *
     *  @param Sender - the sender that sent the message
     *  @return None
     */
    func proceedBackwards(sender: AnyObject) {
        if navigationController?.viewControllers.count > 1 {
            RegistrationViewModel.sharedInstance.decrementCurrentField()
            dispatch_async(GlobalMainQueue, {
                self.navigationController?.popViewControllerAnimated(true)
            })
        } else {
            dispatch_async(GlobalMainQueue, {
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    /** Submit the registration and process it through the view model
     *
     *  @param None
     *  @return None
     */
    func submitRegistration() {
        showLoading()
        RegistrationViewModel.sharedInstance.submitRegistrationData({success, error in
            if error != nil {
                dispatch_async(GlobalMainQueue, {
                    self.hideLoading()
                    self.alertController(withTitles: ["Ok"], message: (error?.localizedDescription)!, callbackHandler: [nil])
                })
            } else {
                dispatch_async(GlobalMainQueue, {
                    self.hideLoading()
                    self.dismissViewControllerAnimated(true, completion: {void in
                    })
                })
            }
        })
    }
}

/** Extension for abstracting away some of the view logic
 */
extension RegistrationViewController {
    /** Button item image for the current registration page, which is dependant on the current field being filled out.
     *
     *  @param field - the field that is being evaluated
     *  @return UIImage - the image for the field
     */
    private func buttonItemImage(forField field: RegistrationViewModel.RegistrationField) -> UIImage {
        switch field {
        case .FullName:
            return xInSquareImage!
        default:
            return backwardArrowImage!
        }
    }
    
    /** The debug / validation message associated with a field
     *
     *  @param field - the field that the validation message is for
     *  @return String - the string value of the validation / debug message
     */
    private func debugMessage(forField field: RegistrationViewModel.RegistrationField) -> String {
        switch field {
        case .Email:
            return "Please enter a valid email address"
        case .FullName:
            return "Please enter your full name, both first and last"
        case .Password:
            return "Password must be at least 8 characters"
        default:
            return ""
        }
    }
    
    /** Get the data value for a specific field
     *
     *  @param field - the field enumeration value
     *  @return String - the value of the field.
     */
    private func dataValue(forField field: RegistrationViewModel.RegistrationField) -> String? {
        switch field {
        case .FullName: return fullNameTextField.text
        case .Email: return emailTextField.text
        case .Password: return passwordTextField.text
        default: return nil
        }
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    /* Delegate callback for text field should return.
     * Validates entry and then returns true if valid.
     * @return - Bool - Determination of whether the registration process can continue or not.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        /* Process the submission by validating */
        let currentField = RegistrationViewModel.sharedInstance.currentField!
        
        if validateField(currentField, withValue: textField.text) {
            processSubmission(self)
            return true
        } else {
            showDebugLabel(withText: debugMessage(forField: currentField))
            return false
        }
    }
}

