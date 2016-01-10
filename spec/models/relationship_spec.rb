require 'rails_helper'

RSpec.describe Relationship, type: :model do
  subject(:relationship) { FactoryGirl.create :relationship }

  context "validation" do
    it 'requires :follower_id' do
      expect(relationship).to validate_presence_of :follower_id
    end

    it 'requires :followed_id' do
      expect(relationship).to validate_presence_of :followed_id
    end
  end

  context "association" do
    it "belongs to followed" do
      expect(relationship).to belong_to(:followed)
    end

    it "belongs to follower" do
      expect(relationship).to belong_to(:follower)
    end
  end

end
