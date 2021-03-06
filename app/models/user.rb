class User < ActiveRecord::Base
  include HasEvents
  include Humanizer
  # humanizer validation will trigger only for anonymous users except for test users
  attr_accessor :skip_humanizer
  require_human_on :create, if: :is_anonymous?, unless: :skip_humanizer

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable
  alias_method :user_id, :id

  validates :username, presence: true, uniqueness: true
  validates_confirmation_of :email, message: I18n.t('user.email_must_match')
  validates_presence_of :email_confirmation, on: :create, unless: :is_anonymous?
  # ensure user is permitted to edit object
  # either if the user is an admin or if
  # the user has created the object
  # Note only event objects have user_ids
  def can_edit?(object)
    self.is_admin? || id == object.try(:user_id)
  end

  def make_admin
    self.is_admin = true
    self.save
  end

  # the name method is an alias used
  # by the page title helper
  def name
    username
  end

  def to_schema
    unless self.is_anonymous?
      { 
        '@context': 'http://schema.org',
        '@type': 'Person', 
        name: self.username,
        description: self.description
      } 
    end
  end

end
