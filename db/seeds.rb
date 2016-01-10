User.delete_all

chicago = User.create({ token: 'chicago', nickname: 'bulldog', os: 'ios' \
  , version: '9.1.0'})
chicago.avatar = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/images/avatar.jpg", "image/jpg")
chicago.save
copenhagen = User.create({ token: 'copenhagen', nickname: 'red nose' \
  , os: 'android', version: 'jellybean'})
copenhagen.avatar = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/images/avatar.jpg", "image/jpg")
copenhagen.save
Relationship.create follower_id: chicago.id, followed_id: copenhagen.id
