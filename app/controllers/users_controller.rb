# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if UserRegistration.new(@user).call
      handle_successful_creation
    else
      handle_failed_creation
    end
  rescue StandardError => e
    handle_creation_error(e)
  end

  def update
    if current_user.update(user_params)
      flash[:success] = t('.success')
      redirect_to profile_path, status: :see_other
    else
      flash.now[:error] = current_user.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def handle_successful_creation
      sign_in @user
      redirect_to learnings_path,
                  status: :see_other,
                  flash: { success: t('.welcome', name: @user.name) }
    end

    def handle_failed_creation
      flash.now[:error] = @user.errors.full_messages
      render '/devise/registrations/new', status: :unprocessable_entity
    end

    def handle_creation_error(error)
      flash.now[:error] = ["Error: #{error.message}. Please try again."]
      render '/devise/registrations/new', status: :unprocessable_entity
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password)
    end
end
