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

    if @learning.blank?
      redirect_to learnings_path, status: :see_other, flash: { error: t(".error") }
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # TODO: come back and try to see later how to reduce the method size further
  def destroy
    @learning = Learning.find_by(id: params[:id])
    return redirect_to learnings_index_path, status: :see_other, flash: { error: t(".not_found") } if @learning.blank?

    if @learning.destroy
      flash.now[:success] = t(".success")
      @learnings = current_user.learnings
      respond_to do |format|
        format.turbo_stream { render :destroy, status: :see_other }
        # Below code is useful when you have JS disable on the browser, then a normal HTML request is received
        format.html { redirect_to learnings_index_path, status: :see_other, flash: { success: t(".success") } }
      end
    else
      @learnings = current_user.learnings
      flash.now[:error] = @learning.errors.full_messages
      respond_to do |format|
        format.turbo_stream { render :destroy, status: :see_other }
        # Below code is useful when you have JS disable on the browser, then a normal HTML request is received
        format.html { redirect_to learnings_index_path, status: :see_other, flash: { error: @learning.errors.full_messages } }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  private

    def learnings_params
      params.require(:learning).permit(:lesson, :description, :public, :organization_id, learning_category_ids: [])
    end
end
