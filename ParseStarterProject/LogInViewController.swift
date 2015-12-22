//
//  LogInViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Pedro Alonso on 21/12/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var saveLogInSwitch: UISwitch!
    
    
    var user: PFUser!
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let savedName = defaults.stringForKey("username") {
            
            usernameText.text = savedName
        }
        
        if let savedPassword = defaults.stringForKey("password") {
            
            passwordText.text = savedPassword
            
        }
        
        usernameText.delegate = self
        passwordText.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func logInButtonTapped(sender: UIButton) {
     
        if usernameText.text! != "" && passwordText.text! != "" {
            
            if saveLogInSwitch.on {
                
                defaults.setObject(usernameText.text!, forKey: "username")
                defaults.setObject(passwordText.text!, forKey: "password")

            }
            
            PFUser.logInWithUsernameInBackground(usernameText.text!, password: passwordText.text!) {
                
                (success: PFUser?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    print("entering")
                    self.user = success
                    print(self.user)
                    
                    sleep(1)
                    
                    self.performSegueWithIdentifier("MapViewSegue", sender: self)
                    
                } else {
                    
                    print(" there has been an error here \(error)")
                }
                
            }
            
            
        } else {
            
            displayError("Error", message: "Los campos no pueden estar vacios.")
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "MapViewSegue" {
            
            let mapViewVC = segue.destinationViewController as! MapTackingViewController
            
            mapViewVC.user = user
        }
    }

    
    func displayError(error: String, message: String) {
        
        let alert: UIAlertController = UIAlertController(title: error, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { alert in
            
            //self.dismissViewControllerAnimated(true, completion: nil)
            })
        presentViewController(alert, animated: true, completion: nil)
    
    }
    
    // MARK: Text fields functions to end
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        textField.resignFirstResponder()
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        view.endEditing(true)
    }

}
