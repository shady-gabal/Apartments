class Client < User
  default_scope { where(role: User::Role::Client) }
end