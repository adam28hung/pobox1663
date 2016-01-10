require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { FactoryGirl.create :user }

  context "validation" do

    it 'requires :token' do
      expect(user).to validate_presence_of :token
    end

    it 'requires :nickname' do
      expect(user).to validate_presence_of :nickname
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

end
