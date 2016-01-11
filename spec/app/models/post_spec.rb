require 'rails_helper'

RSpec.describe Post, type: :model do
  subject(:user) { FactoryGirl.create :user }
  subject(:post) { FactoryGirl.create :post }

  context "validation" do
    before(:each) do
      user.posts << post
    end

    it 'requires :message' do
      expect(post).to validate_presence_of :message
    end

    it 'requires :site_name' do
      expect(post).to validate_presence_of :site_name
    end

    it 'requires :lat' do
      expect(post).to validate_presence_of :lat
    end

    it 'requires :lng' do
      expect(post).to validate_presence_of :lng
    end
  end

  context "association" do
    it "belongs to a user" do
      expect(post).to belong_to(:user)
    end
  end

end
