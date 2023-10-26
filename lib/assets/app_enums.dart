enum BusinessCategories {
  beauty,
  clothing,
  food,
}

enum UserPermissions {
  admin,
  beneficiary,
  business,
  user,
}

enum UserStatus {
  active,
  pending,
}

enum BusinessStatus {
  active,
  inactive,
  pending,
}

enum AuthStatus {
  businessLoggedIn,
  error,
  initial,
  loading,
  userLoggedIn,
  userLoggedInNotVerified,
  userNotLoggedIn,
}
