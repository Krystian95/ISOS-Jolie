
// Login

type Login: void {
   .username: string
   .password: string
}

type LoginResponse: void {
	.authenticated: bool
	.authKey?: string
	.message: string
}

// Check account

type CheckAccount: void{
	.authKey: string
}

type CheckAccountResponse: void {
	.authenticated: bool
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

type LoginResponseL: void {
	.sid: string
}

type tok: void {
	.value: int
}

type resu: void {
	.val: bool
}


interface BancaInterface {
	RequestResponse:	login(Login)(LoginResponse),
						checkAccount(CheckAccount)(CheckAccountResponse),
						payment(bankRequest)(bankResponse),
						checkPayment(tok)(resu)
	OneWay: 			logout(LoginResponseL)
}
