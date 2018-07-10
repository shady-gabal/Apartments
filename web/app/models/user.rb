class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :apartments, foreign_key: 'realtor_id'

  module Role
    CLIENT = "client"
    REALTOR = "realtor"
    ADMIN = "admin"
  end

  def admin?
    self.role === Role::ADMIN
  end

  def realtor?
    self.role === Role::REALTOR
  end

  def client?
    self.role === Role::CLIENT
  end
end
