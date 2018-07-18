class Realtor < User
  default_scope { where(role: User::Role::Realtor) }
end