
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

type Payment: void {
	.authKey: string
	.amount: double
	.receiverUsername: string
}

type PaymentResponse: void {
	.response: bool
	.transactionToken: string
	.message: string
}

// Check payment

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
						payment(Payment)(PaymentResponse),
						checkPayment(tok)(resu)
	OneWay: 			logout(LoginResponseL)
}
