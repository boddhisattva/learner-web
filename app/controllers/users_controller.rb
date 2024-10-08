class UsersController < ApplicationController
  before_action :authenticate_user!, only: [ :update ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      sign_in @user

      @organization = Organization.create(members: [ @user ])

      redirect_to feed_index_path,
        status: :see_other,
        flash: { success: t(".welcome", name: @user.name) }
    else
      flash.now[:error] = @user.errors.full_messages
      render "/devise/registrations/new", status: :unprocessable_entity
    end
  end

  def update
    if current_user.update(user_params)
      flash[:success] = t(".success")
      redirect_to profile_path, status: :see_other
    else
      flash.now[:error] = current_user.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end
end
