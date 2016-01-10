class User < ActiveRecord::Base
  has_many :posts
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

end
