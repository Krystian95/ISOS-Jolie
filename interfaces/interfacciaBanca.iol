
// Login

type Login: void {
   .username: string
   .password: string
}

type LoginResponse: void {
	.authenticated: bool
	.sid?: string
	.message: string
}

// Payment

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

type LoginResponseL: void {
	.sid: string
}

type tok: void {
	.value: int
}

type resu: void {
	.val: bool
}


interface BankInterface {
	RequestResponse:	login(Login)(LoginResponse),
						payment(bankRequest)(bankResponse),
						checkAccount(accountRequest)(accountResponse),
						checkPayment(tok)(resu)
	OneWay: 			logout(LoginResponseL)
}
