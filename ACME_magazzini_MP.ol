
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

			println@Console("Verifico disponibilità componenti e accessori nel MP per l'ordine #" + idOrdine)();

			tuttiAccessoriOrdinePresentiMP = true;
			tuttiComponentiOrdinePresentiMP = true;

			// Accessori

			query = "SELECT idAccessorio
					 FROM ordine_has_accessorio
					 WHERE idOrdine = " + idOrdine;
        	query@Database( query )( accessoriOrdine );

	        if ( #accessoriOrdine.row > 0 ) {
	        	// Elenco degli accessori presenti nel MP per uno specifico ordine
	        	query = "SELECT idAccessorio
	        			 FROM ordine_has_accessorio
	        			 WHERE idOrdine = " + idOrdine + " AND
	        			 idAccessorio IN (
							SELECT idAccessorio FROM (
								SELECT idAccessorio
								FROM magazzino
								LEFT JOIN magazzino_has_accessorio ON magazzino.idMagazzino = magazzino_has_accessorio.idMagazzino
								WHERE tipologia = 'Primario'
							) AS accessori_MP
						)";
        		query@Database( query )( accessoriOrdinePresentiMP );

        		if ( #accessoriOrdinePresentiMP.row != #accessoriOrdine.row ) {
        			tuttiAccessoriOrdinePresentiMP = false
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
						 WHERE idOrdine = 27 AND idComponente IN (
							SELECT idComponente
    						FROM magazzino_has_componente
    						WHERE idMagazzino = " + global.idMagazzino + "
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

	        println@Console(response.response)()
	    }
	] {
		println@Console("[verificaDisponibilitaComponentiAccessoriMP] COMPLETED")()
	}
}
