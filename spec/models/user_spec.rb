require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { FactoryGirl.create :user }

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

end
