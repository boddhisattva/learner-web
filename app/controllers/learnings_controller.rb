class LearningsController < ApplicationController
  before_action :authenticate_user!

  def index
    @learnings = current_user.learnings.order(created_at: :desc)
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

  def show
    @learning = Learning.find_by(id: params[:id])
  end

  def destroy
    @learning = Learning.find_by(id: params[:id])

    if @learning.destroy
      redirect_to learnings_index_path,
        status: :see_other,
        flash: { success: t(".success") }
    else
      # TODO: Come back to surely see that the code actually goes here through a relevant spec
      flash.now[:error] = @learning.errors.full_messages
    end
  end

  private

    def learnings_params
      params.require(:learning).permit(:lesson, :description, :public, :learning_category_ids, :organization_id)
    end
end
