enum UserPermissions {
  admin, //Can do everything
  beneficiary, //Can only see the promotions
  business, //Can create and manage promotions
  user, //Can only see the promotions
}

enum UserStatus {
  active, //If the user has verified the email
  pending, //If the user has not verified the email
}

enum BusinessStatus {
  active, //If the business has been approved
  inactive, //If the business has been rejected or canceled
  pending, //If the business is under review
}

enum BusinessSubscriptionStatus {
  active, //If the last transaction is not expired
  inactive, //If the business has no transactions
  pending, //If the business has a transaction but is not approved yet
  markToRenew, //If the business has a transaction but is expired and needs to renew
  freeTrial, //If the business is in the free trial period
  canceled, //If the business has canceled the subscription
}

enum PromotionStatus {
  active, //If the promotion is active
  inactive, //If the promotion is inactive
  pending, //If the promotion is under review
}

//This enum is used to manage the status of the authentication in the app
enum AuthStatus {
  businessLoggedIn, //If the user is type business and is logged in
  userLoggedIn, //If the user is type user and is logged in
  userNotLoggedIn, //If the user is not logged in
  initial, //If the app is in the initial state
  loading, //If the app is loading
  error, //If there is an error
  userLoggedInNotVerified, //If the user is logged in but not verified
}

//This enum is used to manage the status of the some cubits in the app
enum BusinessViewCubitStatus {
  error,
  initial,
  loading,
  success,
}
