//
//  TableCellAdapter.swift
//  OrarioAnfe
//
//  Created by Giuseppe Davi on 09/12/14.
//  Copyright (c) 2014 Giuseppe Davì. All rights reserved.
//

import Foundation
import UIKit

class TableCellAdapter : UITableViewCell {
    
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var giorno: UILabel!
    @IBOutlet weak var giornoMese: UILabel!
    @IBOutlet weak var mese: UILabel!
    @IBOutlet weak var orario: UILabel!
    @IBOutlet weak var corso: UILabel!
    @IBOutlet weak var docente: UILabel!
    @IBOutlet weak var materia: UILabel!
    @IBOutlet weak var oreSvolte: UILabel!
    
    
    func loadItems(lezione : Lezione) -> Void
    {
        var df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        var data = df.dateFromString(lezione.data)
        
        self.giorno.text = getNomeGiorno(data)
        self.giornoMese.text = getGiornoMese(data)
        self.mese.text = getNomeMese(data)
        self.orario.text = lezione.oraInizio! + "-" + lezione.oraFine!
        self.corso.text = lezione.codiceCorso
        self.materia.text = lezione.modulo
        self.docente.text = lezione.nomeFormatore
        self.oreSvolte.text = "ore svolte: " + String(lezione.oreModulo!)
    }
    
    func getNomeMese(data : NSDate!) -> String
    {
        var dfMese = NSDateFormatter()
        dfMese.locale = NSLocale(localeIdentifier: "it_IT")
        dfMese.dateFormat = "MMMM"
        
        return data? != nil ? dfMese.stringFromDate(data!) : "?"
    }
   
    
    func getNomeGiorno(data : NSDate!) -> String
    {
        var dfGiorno = NSDateFormatter()
        dfGiorno.locale = NSLocale(localeIdentifier: "it_IT")
        dfGiorno.dateFormat = "EEEE"
        
        return data? != nil ? dfGiorno.stringFromDate(data!) : "?"
    }
    
    func getGiornoMese(data : NSDate!) -> String
    {
        var dfGiorno = NSDateFormatter()
        dfGiorno.locale = NSLocale(localeIdentifier: "it_IT")
        dfGiorno.dateFormat = "dd"
        
        return data? != nil ? dfGiorno.stringFromDate(data!) : "?"
    }
    
}

/*
classe = "\"\"";
"codice_corso" = "PREFTRAD - COD. 1133";
committente = "Via VilLa Nave";
corso = "Preformazione in lavorazione di piccoli oggetti delle tradizioni popolari";
data = "2014-06-09";
"data_it" = "09-06-14";
docente = Marchiafava;
fine = "11:00:00";
fromHour = "08:00";
giorno = lun;
id = 7348;
"id_committente" = 0;
"id_corso" = 43;
"id_docente" = 78;
"id_materia" = 0;
inizio = "08:00:00";
"last_update" = "2014-10-02 10:37:35";
materia = "Realizzazione oggetti tradizionali";
note = "";
ore = 3;
"ore_corso" = 397;
"ore_docente" = 307;
"ore_modulo" = 90;
sede = Palermo3;
toHour = "11:00";
tutor = "";

*/