//
//  Lezione.swift
//  OrarioAnfe
//
//  Created by anfe on 03/01/15.
//  Copyright (c) 2015 Giuseppe Davì. All rights reserved.
//

import Foundation
//import SQLite

class Lezione
{
    var lastUpdate : NSDate! // YYYY-mm-dd hh:ii:ss
    // orario lezione
    var data : String! // YYYY-mm-dd
    var oraInizio : String! // hh:ii:ss
    var oraFine : String! // hh:ii:ss
    // formatore
    var idFormatore : Int!
    var nomeFormatore : String!
    // modulo lezione
    var modulo : String!
    // dati del corso
    var idCorso : Int!
    var titoloCorso  : String!
    var codiceCorso  : String! // es.: IPHONEANDR - Cod. 3362
    var indirizzoCorso : String!
    var sedeCorso  : String!
    var oreCorso : Int!
    var oreFormatore : Int!
    var oreModulo : Int!
    

    // Constructor
    init(lastUpdate: NSDate, data: String, oraInizio: String, oraFine: String, idFormatore: Int, nomeFormatore: String, modulo: String, idCorso: Int, titoloCorso: String, codiceCorso: String, indirizzoCorso: String, sedeCorso: String, oreCorso: Int, oreFormatore: Int, oreModulo: Int)
    {
        self.lastUpdate = lastUpdate
        self.data = data
        self.oraInizio = oraInizio
        self.oraFine = oraFine
        self.idFormatore = idFormatore
        self.nomeFormatore = nomeFormatore
        self.modulo = modulo
        self.idCorso = idCorso
        self.titoloCorso = titoloCorso
        self.codiceCorso = codiceCorso
        self.indirizzoCorso = indirizzoCorso
        self.sedeCorso = sedeCorso
        self.oreCorso = oreCorso
        self.oreFormatore = oreFormatore
        self.oreModulo = oreModulo
    }
    
    func isNext() -> Bool
    {
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dataString = df.stringFromDate(NSDate())
 
        return self.data >= dataString
    }
}
