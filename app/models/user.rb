class User < ActiveRecord::Base

  has_many :posts
  has_many :followships, foreign_key: 'follower_id', class_name:  'Relationship'
  has_many :followed_users, through: :followships, source: :followed

  has_many :fanships, foreign_key: 'followed_id', class_name:  'Relationship'
  has_many :fans, through: :fanships, source: :follower

  has_attached_file :avatar \
  , styles: { medium: "300x300>", thumb: "100x100>" } \
  , default_url: "/images/:style/missing.png" \
  , path: ":rails_root/public/uploads/images/:id_:style_:fingerprint.:extension" \
  , url: "/uploads/images/:id_:style_:fingerprint.:extension"

  validates_presence_of :token, :os, :version, :nickname
  validates :token, :nickname, uniqueness: true
  validates :avatar, attachment_presence: true
  validates_attachment :avatar \
  , content_type: { content_type: /^image\/(jpg|jpeg|png|x-png)$/ } \
  , size: { in: 0..10.megabytes }

  # Follows a user.
  def follow(other_user)
    followships.create(followed_id: other_user.id) unless following?(other_user)
  end

  # Unfollows a user.
  def unfollow(other_user)
    followships.find_by(followed_id: other_user.id).destroy if following?(other_user)
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    followed_users.include?(other_user)
  end

end
