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
		.username = "ACME";
		.password = "5tueh34tw24yrfhswe4";
		.authKey = "68537ae1-820e-45c7-b2e8-da9f465787dd";
		.balance = 0
	}

	with( global.users[1] ){
		.username = "andrea";
		.password = "r56uwe457w4grwe4";
		.authKey = "fed4b15d-4e9b-43e0-ad72-a969232f7d5e";
		.balance = 10000.0
	}

	with( global.users[2] ){
		.username = "lorenzo";
		.password = "648the346tsdr4";
		.authKey = "8375e4a5-5369-462c-ba6d-c97834e60263";
		.balance = 11100.0
	}

	with( global.users[3] ){
		.username = "cristian";
		.password = "ku5ierydt0rthde";
		.authKey = "24bd1e11-0ad5-4293-96bf-ae3c953d824c";
		.balance = 15000.0
	}
}

execution { sequential }

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
			response.message = "L'authKey " + request.authKey + " non e' valida. Riesegui il login per favore.";

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
	
	[
		payment(request)(response){

			response.result = false;
			response.message = "L'authKey " + request.authKey + " non e' valida. Riesegui il login per favore.";

			for(i = 0, i < #global.users, i++){
				if(global.users[i].authKey == request.authKey) { // origin
					if(global.users[i].balance >= request.amount){

						response.message = "L'utente richiesto (" + request.receiverUsername + ") non esiste!";

						for(j = 0, j < #global.users, j++){
							if(global.users[j].username == request.receiverUsername){ // destination

								println@Console("Saldo conto di " + global.users[i].username + ": EUR " + global.users[i].balance)();
								println@Console("Saldo conto di " + global.users[j].username + ": EUR " + global.users[j].balance + "\n")();

								global.users[i].balance -= request.amount;
								global.users[j].balance += request.amount;

								println@Console("Saldo conto di " + global.users[i].username + ": EUR " + global.users[i].balance)();
								println@Console("Saldo conto di " + global.users[j].username + ": EUR " + global.users[j].balance)();

								response.result = true;
								response.message = "Pagamento di EUR " + request.amount + " accettato e correttamente versato sul conto di " + request.receiverUsername;

								global.users[i].payments[#global.users[i].payments].transactionToken = new;
								global.users[i].payments[#global.users[i].payments - 1].amount = request.amount;

								response.transactionToken = global.users[i].payments[#global.users[i].payments - 1].transactionToken;

								arraySize = #global.users[i].payments - 1;

								println@Console("global.users["+i+"].payments["+arraySize+"].amount = " + global.users[i].payments[arraySize].amount)();
								println@Console("global.users["+i+"].payments["+arraySize+"].transactionToken = " + global.users[i].payments[arraySize].transactionToken)()
							}
						}
					} else {
						response.message = "Saldo non sufficiente! Balance: EUR " + global.users[i].balance + ". Payment request: EUR " + request.amount
					}
				}
			}
		}
	] {
		println@Console("\n[payment] COMPLETED\n")()
	}

	[
		checkPayment(request)(response){

			response.result = false;
			response.message = "Il pagamento con token " + request.transactionToken + " NON e' stato verificato correttamente";

			authKeyVerified = false;

			for(i = 0, i < #global.users, i++){
				if(global.users[i].authKey == request.authKey) {
					authKeyVerified = true
				}
			}

			if(authKeyVerified) {
				for(i = 0, i < #global.users, i++){
					for(j = 0, j < #global.users[i].payments, j++){
						if(global.users[i].payments[j].transactionToken == request.transactionToken){
							if(global.users[i].payments[j].amount == request.amount){
								response.result = true;
								response.message = "Il pagamento con token " + request.transactionToken + " e' stato verificato correttamente"
							} else {
								response.message = "Il pagamento con token " + request.transactionToken + " esiste ma NON e' dell'importo richiesto"
							}
						}
					}
				}
			} else {
				response.message = "L'authKey " + request.authKey + " non e' valida. Riesegui il login per favore."
			}

			println@Console(response.message)()
		}
	] {
		println@Console("\n[checkPayment] COMPLETED\n")()
	}
}