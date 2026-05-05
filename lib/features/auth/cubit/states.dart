abstract class LoginStates {}

class LoginInitialState extends LoginStates {}

class ValidationState extends LoginStates {}
class PasswordVisibilityChanged extends LoginStates {}

class LoginLoadingState extends LoginStates {}
class LoginSuccessState extends LoginStates {}
class LoginErrorState extends LoginStates {}
class AccountNotVerifiedState extends LoginStates {}

class SignUpLoadingState extends LoginStates {}
class SignUpSuccessState extends LoginStates {}
class SignUpErrorState extends LoginStates {}

class SendOtpLoadingState extends LoginStates {}
class SendOtpSuccessState extends LoginStates {}
class SendOtpErrorState extends LoginStates {}

class VerifyOtpLoadingState extends LoginStates {}
class VerifyOtpSuccessState extends LoginStates {}
class VerifyOtpErrorState extends LoginStates {}

class ForgotPasswordRequestLoadingState extends LoginStates {}
class ForgotPasswordRequestSuccessState extends LoginStates {}
class ForgotPasswordRequestErrorState extends LoginStates {}

class ResetPasswordLoadingState extends LoginStates {}
class ResetPasswordSuccessState extends LoginStates {}
class ResetPasswordErrorState extends LoginStates {}
