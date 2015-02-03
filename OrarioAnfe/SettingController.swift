//
//  SettingController.swift
//  OrarioAnfe
//
//  Created by Giuseppe Davi on 15/12/14.
//  Copyright (c) 2014 Giuseppe Davì. All rights reserved.
//

import Foundation
import UIKit

class SettingController : UITableViewController
{
    let defaults : NSUserDefaults = NSUserDefaults.standardUserDefaults()
    let app : Application! = Application.sharedInstance
    
    @IBOutlet weak var corsoSelezionato: UILabel!
    @IBOutlet weak var formatoreSelezionato: UILabel!
    @IBOutlet weak var done: UIBarButtonItem!
    
    @IBAction func saveSetting(sender: UIBarButtonItem) {
        app.resetOrario()
        let storyBoard = UIStoryboard(name : "Main", bundle : nil)
        let viewController = storyBoard.instantiateViewControllerWithIdentifier("orario") as UIViewController
        
        presentViewController(viewController, animated: false, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        loadStrings()
    }
    
    @IBAction func unwindToThisViewController(segue: UIStoryboardSegue)
    {
        println("exit")
    }
    
    private func loadStrings()
    {
        let corsoSelezionato = app.getCorsoSelezionato()
        let formatoreSelezionato = app.getFormatoreSelezionato()
        
        done.enabled = corsoSelezionato? != nil || formatoreSelezionato? != nil

        self.corsoSelezionato.text = corsoSelezionato? != nil ? corsoSelezionato!["corso"]?.lowercaseString.capitalizedString :  NSLocalizedString("SETTING_CORSO", comment: "Descrizione impostazione corso selezionato")
        self.formatoreSelezionato.text = formatoreSelezionato? != nil ? formatoreSelezionato!["docente"]?.lowercaseString.capitalizedString : NSLocalizedString("SETTING_FORMATORE", comment: "Descrizione impostazione formatore selezionato")
    }
}
