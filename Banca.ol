include "console.iol"
include "time.iol"
include "interfaces/BancaInterface.iol"

// Porta -> Banca

inputPort Banca {
	Location: "socket://localhost:8017"
	Protocol: soap
	Interfaces: BancaInterface
}

init {

	with( global.users[0] ){
		.username = "andrea";
		.password = "r56uwe457w4grwe4";
		.authKey = "fed4b15d-4e9b-43e0-ad72-a969232f7d5e";
		.balance = 10000.0
	}

	with( global.users[1] ){
		.username = "lorenzo";
		.password = "648the346tsdr4";
		.authKey = "8375e4a5-5369-462c-ba6d-c97834e60263";
		.balance = 11100.0
	}

	with( global.users[2] ){
		.username = "cristian";
		.password = "ku5ierydt0rthde";
		.authKey = "24bd1e11-0ad5-4293-96bf-ae3c953d824c";
		.balance = 15000.0
	}

	global.userAuthenticated = false;
	global.idToken = 1 //se è 0 è nullo il pagamento
}

execution { concurrent }

init{
	println@Console("\nBANCA is running...\n")()
}

main {

	[
		login(request)(response) {

			response.authenticated = false;
			response.message = "Login NON autorizzato (userame o password errati) per " + request.username;

			for(i = 0, i < #global.users, i++){
				if (global.users[i].username == request.username && global.users[i].password == request.password) {
				 	response.authKey = global.users[i].authKey;
					response.authenticated = true;
					response.message = "Login effettuato correttamente da " + request.username;

					println@Console("user authKey = " + global.users[i].authKey + "\n")()
				}
			}

			println@Console(response.message)()
		}
	] {
		println@Console("\n[login] COMPLETED\n")()
	}

	[
		checkAccount(request)(response){

			response.authenticated = false;
			response.message = "L'authKey " + request.authKey + " non e' valida. Riesegui il login.";

			for(i = 0, i < #global.users, i++){
				if(global.users[i].authKey == request.authKey) {
					response.authenticated = true;
					response.message = "Saldo conto di " + global.users[i].username + ": EUR " + global.users[i].balance
				}
			}

			println@Console(response.message)()
		}
	] {
		println@Console("\n[checkAccount] COMPLETED\n")()
	}

	[checkPayment(tok)(resul){
		control=false;
		if (tok.value!=0) {
			if (tok.value<=global.idToken) {
				resul.val=true;
				control=true
			}
		};
		if (!control) {
			resul.val=false
		};
		println@Console("Controllo di Acme sul token rilasciato numero "+tok.value)()
	}]
	
	[payment(request)(response){
		if (global.userAuthenticated) {
			nUsers = #global.users;
			controllo=false;
			response.token=0;
			println@Console("Pagamento richiesto dall'utente con la chiave: " + request.authKey)();
			for( i = 0, i < nUsers, i++){
				if( request.authKey == global.users[i].authKey ) {
					if(global.users[i].balance > request.amount){
						global.users[i].balance = global.users[i].balance - request.amount;
						response.response = "Pagamento avvenuto con successo.";
						response.token=global.idToken;
						global.idToken=global.idToken+1;
						println@Console(response.response)()
					}else{
						response.response = "Pagamento fallito: deposito non sufficente.";
						println@Console(response.response)()
					};
					println@Console(response.response)();
					i = nUsers;
					controllo=true
				}
			};
			if (!controllo) {
				response.response = "Chiave inserita sbagliata.";
				println@Console(response.response)()
			}
		}else {
			response.response = "Errore, login non effettuato correttamente.";
			println@Console(response.response)()
		}

	}] {nullProcess}
	
	[logout(req)] {
		global.userAuthenticated=false;
		println@Console("Logout effettuato")()
	}
}