
include "console.iol"
include "string_utils.iol"
include "database.iol"

include "interfaces/ACMEMagazzinoInterface.iol"

// Porta ACME Gestione Ordini -> ACME Magazzino Principale
inputPort MagazzinoPrincipale {
	Location: "socket://localhost:8006"
	Protocol: soap
	Interfaces: ACMEMagazzinoInterface
}

execution { concurrent }

init
{
	with(connectionInfo) {
        .host = "127.0.0.1";
        .driver = "mysql";
        .port = 3306;
        .database = "acme?serverTimezone=Europe/Rome";
        .username = "root";
        .password = "root"
    };
    
    connect@Database(connectionInfo)();
    println@Console("\nConnection to database: SUCCESS")();

    println@Console("\nACME MAGAZZINO PRINCIPALE running...\n")();

	// Id Magazzino
	global.idMagazzino = 1
}

main
{
	[
		verificaDisponibilitaComponentiAccessori ( params )( response ) {

			idOrdine = params.idOrdine;

			println@Console("Verifico disponibilità componenti e accessori nel MP per l'ordine #" + idOrdine + "\n")();

			tuttiAccessoriOrdinePresentiMP = true;
			tuttiComponentiOrdinePresentiMP = true;

			// Accessori

			query = "SELECT idAccessorio
					 FROM ordine_has_accessorio
					 WHERE idOrdine = " + idOrdine;
        	query@Database( query )( accessoriOrdine );

	        if ( #accessoriOrdine.row > 0 ) {
	        	// Elenco degli accessori presenti nel MP per uno specifico ordine
	        	query = "SELECT
							ordine_has_accessorio.idOrdine,
						    ordine_has_accessorio.idAccessorio,
						    ordine_has_accessorio.quantitaAccessorio AS qta_richiesta,
						    magazzino_has_accessorio.idMagazzino,
						    magazzino_has_accessorio.quantita AS qta_disponibile
						FROM ordine_has_accessorio
						LEFT JOIN magazzino_has_accessorio ON ordine_has_accessorio.idAccessorio = magazzino_has_accessorio.idAccessorio
						WHERE ordine_has_accessorio.idOrdine = " + idOrdine +" AND magazzino_has_accessorio.idMagazzino = " + global.idMagazzino;
        		query@Database( query )( accessoriOrdineMP );

        		if(#accessoriOrdine.row != #accessoriOrdineMP.row){
        			tuttiAccessoriOrdinePresentiMP = false
        		}

        		// Per ogni accessorio prenoto la qta richiesta oppure quella disponibile
        		for ( i = 0, i < #accessoriOrdineMP.row, i++ ) {
        			qta_richiesta = accessoriOrdineMP.row[i].qta_richiesta;
        			qta_disponibile = accessoriOrdineMP.row[i].qta_disponibile;
		            qta_mancante = qta_richiesta - qta_disponibile;

		            idMagazzino = accessoriOrdineMP.row[i].idMagazzino;
		            idAccessorio = accessoriOrdineMP.row[i].idAccessorio;

		           	println@Console("Il magazzino #" + idMagazzino + " possiede "+qta_disponibile+" qta su "+qta_richiesta+" qta richieste (ne mancano "+qta_mancante+") dell'accessorio # "+idAccessorio+" per l'ordine #" + idOrdine + "\n")();

		            if(qta_mancante > 0) {
		            	tuttiAccessoriOrdinePresentiMP = false;

		            	if(qta_disponibile >= qta_richiesta){
		            		qta_prenotabile = qta_richiesta
		            	} else {
		            		qta_prenotabile = qta_disponibile
		            	}

		            	query = "INSERT INTO Magazzino_accessorio_prenotato
				            	(idOrdine, idMagazzino, idAccessorio, quantita)
				            	VALUES
				            	(" + idOrdine + ", " + idMagazzino + ", " + idAccessorio + ", " + qta_prenotabile + ")";
						update@Database( query )( responseNewPrenotazioneAccessorio );
						println@Console("Prenoto " + qta_prenotabile + " qta dell'accessorio #" + idAccessorio + " nel magazzino #" + idMagazzino + " per l'ordine #" + idOrdine + "\n")();

						query = "UPDATE magazzino_has_accessorio
								 SET quantita = quantita - " + qta_prenotabile + "
								 WHERE idMagazzino = " + idMagazzino + " AND idAccessorio = " + idAccessorio;
						update@Database( query )( responseScaloQtaMagazzino );
						println@Console("Ho scalato " + qta_prenotabile + " qta dell'accessorio #" + idAccessorio + " dal magazzino #" + idMagazzino + " poiche' prenotate" + "\n")()
		            }
		        }
	        }

	        // Componenti

	        query = "SELECT *
					 FROM ordine_has_ciclo
					 LEFT JOIN ciclo_has_componente ON ordine_has_ciclo.idCiclo = ciclo_has_componente.idCiclo
					 WHERE idOrdine = " + idOrdine;
        	query@Database( query )( componentiOrdine );

        	if ( #componentiOrdine.row > 0 ) {
	        	// Elenco dei componenti presenti nel MP per uno specifico ordine
	        	query = "SELECT *
						 FROM ordine_has_ciclo
						 LEFT JOIN ciclo_has_componente ON ordine_has_ciclo.idCiclo = ciclo_has_componente.idCiclo
						 WHERE idOrdine = " + idOrdine + " AND idComponente IN (
							SELECT idComponente
    						FROM magazzino_has_componente
    						WHERE idMagazzino = " + global.idMagazzino + " AND quantita > 0
						 )";
        		query@Database( query )( componentiOrdinePresentiMP );

        		if ( #componentiOrdinePresentiMP.row != #componentiOrdine.row ) {
        			tuttiComponentiOrdinePresentiMP = false
        		}
	        }

	        // TODO controllare le quantità e prenotare quelle presenti/necessarie

	        // Finale

	        if ( tuttiAccessoriOrdinePresentiMP && tuttiComponentiOrdinePresentiMP ) {
	        	response.tuttiMaterialiRichiestiPresentiMP = true;
	        	response.response = "Nel MP sono presenti tutti i Componenti/Accessori richiesti dall'ordine #" + idOrdine
	        } else {
				response.tuttiMaterialiRichiestiPresentiMP = false;
				response.response = "Nel MP NON sono presenti tutti i Componenti/Accessori richiesti dall'ordine #" + idOrdine
	        }

	        println@Console(response.response + "\n")()
	    }
	] {
		println@Console("[verificaDisponibilitaComponentiAccessoriMP] COMPLETED")()
	}
}
