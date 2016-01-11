Post.delete_all
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

chicago.follow(copenhagen)
# Relationship.create follower_id: chicago.id, followed_id: copenhagen.id

Post.create([{message: '逛夜市', site_name:'樂華夜市', lat:25.008584, lng:121.5117573, user_id: chicago.id},
             {message: '吃壽司', site_name:'橋壽司', lat:25.0153577, lng:121.5139934, user_id: chicago.id},
             {message: '看風景', site_name:'101觀景台', lat:25.0333646, lng:121.5637253, user_id: chicago.id},
             {message: '逛大街', site_name:'統一阪急百貨', lat:25.0371655, lng:121.5596045, user_id: copenhagen.id},
             {message: '吃咖哩', site_name:'寅樂屋咖啡咖哩小食堂', lat:25.0371655, lng:121.5596045, user_id: copenhagen.id},
             {message: '逛夜市', site_name:'逢甲夜市', lat:24.795929, lng:120.6444043, user_id: copenhagen.id},
             {message: '逛夜市', site_name:'六合夜市', lat:22.6320758, lng:120.296966, user_id: chicago.id},
             {message: '出國玩', site_name:'沖繩北谷', lat:26.2728826, lng:127.6944762, user_id: chicago.id}
             ])
