class AnonymousUserController < ApplicationController
  def new
    @user = User.new(password: 'fake_password')
  end

  # given a username, create a one time user and allow it to create events
  def create
    allow_params_authentication!
    anon_params = AnonymousUser.attributes(whitelist_params)
    @user = User.new(anon_params)
    if @user.save
      # since we're circumventing the usual Devise flow here
      # we need to sign in like this
      sign_in @user
      warden.authenticate!(scope: :user)
      warden.set_user @user
      redirect_to new_event_path
    else
      render action: :new, status: :unprocessable_entity
    end
  end

  private
  def whitelist_params
    params.require(:user).permit(:humanizer_answer, :humanizer_question_id)
  end
end