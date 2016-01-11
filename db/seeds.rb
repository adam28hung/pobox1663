Relationship.delete_all
User.delete_all

chicago = User.create({ device_token: 'chicago', nickname: 'bulldog', os: 'ios' \
  , version: '9.1.0'})
chicago.avatar = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/images/avatar.jpg", "image/jpg")
chicago.save

copenhagen = User.create({ device_token: 'copenhagen', nickname: 'red nose' \
  , os: 'android', version: 'jellybean'})
copenhagen.avatar = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/images/avatar.jpg", "image/jpg")
copenhagen.save
# chicago.follow(copenhagen)
Relationship.create follower_id: chicago.id, followed_id: copenhagen.id
