class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :trackable

  field :name
  field :email
  field :nickname
  field :tweeting, :type => Boolean
  field :twitter_access_token
  field :twitter_access_secret
  has_one :favorite
  has_and_belongs_to_many :favorites, :class_name => "PasokaraFile"
  has_many :sing_logs

  validates_presence_of :name, :nickname
  validates_uniqueness_of :name, :case_sensitive => false
  attr_accessible :name, :nickname, :email, :password, :password_confirmation, :remember_me, :tweeting, :twitter_access_token, :twitter_access_secret

  def favorite?(pasokara)
    favorite ? favorite.pasokara_file_ids.include?(pasokara.id) : false
  end

  def add_favorite(pasokara)
    if favorite
      favorite.pasokara_files << pasokara
    else
      create_favorite
      favorite.pasokara_files << pasokara
    end
  end
end
