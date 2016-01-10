class User < ActiveRecord::Base
  validates_presence_of :token, :os, :version, :nickname
  validates :token, :nickname, uniqueness: true
end
