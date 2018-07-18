class Admin < User
  default_scope { where(role: User::Role::Admin) }
end