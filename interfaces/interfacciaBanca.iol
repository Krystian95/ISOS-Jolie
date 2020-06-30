type bankRequest: void {
	.authKey: string
	.amount: double
	.receiver: string
}

type bankResponse: void {
	.response: string
	.token: int
}

type accountResponse: void {
	.response: string
}

type accountRequest: void{
	.authKey: string
}

type loginData: void {
   .username: string
   .password: string
}

type opMessage: void {
	.sid?: string
	.message: string
}

type opMessageL: void {
	.sid: string
}

type tok: void {
	.value: int
}

type resu: void {
	.val: bool
}


interface BankInterface {
	OneWay: logout(opMessageL)
	RequestResponse:
		login(loginData)(opMessage),
		payment(bankRequest)(bankResponse),
		checkAccount(accountRequest)(accountResponse),
		checkPayment(tok)(resu)
}
