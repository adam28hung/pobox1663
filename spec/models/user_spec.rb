require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { FactoryGirl.create(:user, :with_post) }

  context "validation" do

    it 'requires :token' do
      expect(user).to validate_presence_of :token
    end

    it ':token is unique' do
      expect(user).to validate_uniqueness_of :token
    end

    it 'requires :nickname' do
      expect(user).to validate_presence_of :nickname
    end

    it ':nickname is unique' do
      expect(user).to validate_uniqueness_of :nickname
    end

    it 'requires :os' do
      expect(user).to validate_presence_of :os
    end

    it 'requires :version' do
      expect(user).to validate_presence_of :version
    end

    it "is invalid without a token" do
      user.token = nil
      expect(user).not_to be_valid
    end

    it "is invalid without a nickname" do
      user.nickname = ''
      expect(user).not_to be_valid
    end

    it "is invalid without a os" do
      user.os = ''
      expect(user).not_to be_valid
    end

    it "is invalid without a version" do
      user.version = ''
      expect(user).not_to be_valid
    end
  end

  context "avatar" do
    it { should have_attached_file(:avatar) }
    it { should validate_attachment_presence(:avatar) }
    it { should validate_attachment_content_type(:avatar).
         allowing('image/png', 'image/x-png', 'image/jpg', 'image/jpeg').
         rejecting('text/plain', 'text/xml') }
    it { should validate_attachment_size(:avatar).
         less_than(10.megabytes) }
  end

  context "association" do

    it "has many posts" do
      expect(user).to have_many(:posts)
    end

    it "has many followships" do
      expect(user).to have_many(:followships)
    end

    it "has many followed_users" do
      expect(user).to have_many(:followed_users)
    end

    it "has many fanships" do
      expect(user).to have_many(:fanships)
    end

    it "has many fans" do
      expect(user).to have_many(:fans)
    end
  end

  context "relationship" do
    let(:user_to_follow) {FactoryGirl.create(:user)}

    it "return true if user is #following? other user" do
      user.followships.create(followed_id: user_to_follow.id)
      expect(user.following?(user_to_follow)).to eq(true)
    end

    it "can #follow other user" do
      user.follow(user_to_follow)
      expect(user_to_follow.fans.first).to eq(user)
    end

    it "can #unfollow other user" do
      user.followships.create(followed_id: user_to_follow.id)
      user.unfollow(user_to_follow)
      expect(user_to_follow.fans.count).to eq(0)
    end

  end

end
