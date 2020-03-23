class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # , :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable, :trackable

  has_many :group_users
  has_many :groups, :through => :group_users

  def name
    "#{self.first_name} #{self.last_name}"
  end
  def profile_image
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(self.email)}"
  end

end
