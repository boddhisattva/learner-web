class LearningsController < ApplicationController
  before_action :authenticate_user!

  def index
    @learnings = current_user.learnings
    # TO DO: Add pagination later
  end

  def new
    @learning = Learning.new
  end

  def create
    @learning = Learning.new(learnings_params)
    @learning.creator_id = current_user.id
    @learning.last_modifier_id = current_user.id

    if @learning.save
      redirect_to learnings_index_path,
        status: :see_other,
        flash: { success: t(".success", lesson: @learning.lesson) }
    else
      flash.now[:error] = @learning.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  private

    def learnings_params
      params.require(:learning).permit(:lesson, :description, :public, :learning_categories, :organization_id)
    end
end