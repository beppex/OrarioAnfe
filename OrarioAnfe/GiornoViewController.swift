//
//  GiornoViewController.swift
//  OrarioAnfe
//
//  Created by Giuseppe Davi on 21/12/14.
//  Copyright (c) 2014 Giuseppe Davì. All rights reserved.
//

import Foundation
import UIKit

class GiornoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var currentDay: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var empty: UIView!
    
    var lezioni : Array<Lezione>? = nil
    var giorno : NSDate!
    
    let app : Application! = Application.sharedInstance
    
    
    override func viewDidLoad()
    {
        updateView()
        /*
        lezioni = app.getLezione(giorno)
        self.tableView.layoutMargins = UIEdgeInsetsZero
        
        updateTitle()*/
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lezioni? != nil ? lezioni!.count : 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : GiornoCell = self.tableView.dequeueReusableCellWithIdentifier("giornoCell") as GiornoCell
        
        cell.layoutMargins = UIEdgeInsetsZero
        
        if(lezioni? != nil) {
            let lezione = lezioni![indexPath.row] as Lezione
            cell.loadItems(lezione)
        }
        
        return cell;
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 190
    }
    
    @IBAction func nextDay(sender: AnyObject?)
    {
        giorno = app.getNextDate(giorno)
        updateView()
    }
    
    @IBAction func previousDay(sender: AnyObject?)
    {
        giorno = app.getPreviousDate(giorno)
        updateView()
    }
    
    @IBAction func swipe(sender: UISwipeGestureRecognizer)
    {
        if(sender.direction == UISwipeGestureRecognizerDirection.Left) {
            nextDay(nil)
        }
        else if(sender.direction == UISwipeGestureRecognizerDirection.Right) {
            previousDay(nil)
        }
    }
    
    private func updateView()
    {
        updateTitle()
        lezioni = app.getLezione(giorno)
        
        if(lezioni?.count != 0) {
            self.tableView.hidden = false
            empty.hidden = true
            self.tableView.reloadData()
        }
        else {
            empty.hidden = false
            self.tableView.hidden = true
        }
    }
    
    private func updateTitle()
    {
        if(NSCalendar.currentCalendar().isDateInToday(giorno)) {
            currentDay.title = "Oggi"
        }
        else if(NSCalendar.currentCalendar().isDateInTomorrow(giorno)) {
            currentDay.title = "Domani"
        }
        else if(NSCalendar.currentCalendar().isDateInYesterday(giorno)) {
            currentDay.title = "Ieri"
        }
        else {
            currentDay.title = app.formatOrarioDate(giorno)
        }
    }
}

class GiornoCell : UITableViewCell
{
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var ore_modulo: UILabel!
    @IBOutlet weak var materia: UILabel!
    @IBOutlet weak var corso: UILabel!
    @IBOutlet weak var luogo: UILabel!
    @IBOutlet weak var formatore: UILabel!
    
    func loadItems(lezione : Lezione) -> Void
    {
        self.data.text = lezione.oraInizio + " - " + lezione.oraFine
        self.ore_modulo.text = "ore svolte: " + String(lezione.oreModulo)
        self.materia.text = lezione.modulo
        self.corso.text = lezione.titoloCorso + " (\(lezione.codiceCorso))"
        self.luogo.text = lezione.sedeCorso + ", " + lezione.indirizzoCorso
        self.formatore.text = lezione.nomeFormatore
    }
    
}