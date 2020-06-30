include "console.iol"
include "time.iol"
include "interfaces/interfacciaBanca.iol"



inputPort BankService {
	Location: "socket://localhost:8017"
	Protocol: soap
	Interfaces: BankInterface
}

init {

	global.users[0].name = "cristian";
	global.users[0].password = "password1";
	global.users[0].authKey = "b66887e1-a134-4fff-8b64-f7eb375c2474";
	global.users[0].credit = 15000.0;

	global.users[1].name = "andrea";
  	global.users[1].password = "password2";
	global.users[1].authKey = "1e76ad52-2e4c-49b0-a5e7-8d4637011ee9";
  	global.users[1].credit = 10000.0;

	global.users[2].name = "lorenzo";
  	global.users[2].password = "password3";
	global.users[2].authKey = "48410a17-3dd2-4212-a378-276393fc1ce3";
  	global.users[2].credit = 11100.0;

	global.userAuthenticated = false;
	global.idToken = 1 //se è 0 è nullo il pagamento
}

execution { concurrent }

main {

	[login(loginD)(response) {
		leng = #global.users;
		for( i = 0, i < leng, i++){
			if ( loginD.username ==  global.users[i].name) {
			 	pass= global.users[i].password
			}
		};
		if (loginD.password == pass){
			response.sid = csets.sid = new;
			global.userAuthenticated=true;
			response.message = "Login effettuato";
			println@Console("Login effettuato")()
		} else {
			response.message = "Sbagliato username/password";
			println@Console("Login non permesso")()
		}
	}]
	
	[logout(req)] {
		global.userAuthenticated=false;
		println@Console("Logout effettuato")()
	}

	[checkAccount(request)(response){
		if (global.userAuthenticated) {
			nUsers = #global.users;
			controllo=false;
			for( i = 0, i < nUsers, i++){
				println@Console("Username:" + global.users[i].name)();
				if( request.authKey == global.users[i].authKey ) {
					response.response = "Saldo conto corrente: "+global.users[i].credit;
					controllo=true;
					println@Console(response.response)()
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
	}]

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
					if(global.users[i].credit > request.amount){
						global.users[i].credit = global.users[i].credit - request.amount;
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
}