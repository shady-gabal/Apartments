class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_many :apartments, foreign_key: 'realtor_id'

  validates :name, presence: true, allow_blank: false
  validates :role, presence: true, allow_blank: false

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

  def to_json
    {name: self.name, email: self.provider === "email" ? self.uid : "", role: self.role, id: self.id}
  end
end
