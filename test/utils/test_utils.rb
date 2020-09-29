module TestUtils
  def create_sessions(user = @user)
    master_session = user.master_session.create
    onetime_session = master_session.onetime_session.new
    onetime_session.user = user
    onetime_session.save
    [master_session, onetime_session]
  end
end
