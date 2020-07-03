
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
	.result: bool
	.transactionToken: string
	.message: string
}

// Check payment

type CheckPayment: void {
	.authKey: string
	.transactionToken: string
	.amount: double
}

type CheckPaymentResponse: void {
	.result: bool
	.message: string
}

// Logout

type Logout: void {
	.sid: string
}

interface BancaInterface {
	RequestResponse:	login(Login)(LoginResponse),
						checkAccount(CheckAccount)(CheckAccountResponse),
						payment(Payment)(PaymentResponse),
						checkPayment(CheckPayment)(CheckPaymentResponse)
}
