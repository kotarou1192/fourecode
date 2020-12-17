module TestUtils
  def create_sessions(user = @user)
    user.master_session.create
  end
end
