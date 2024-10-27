class LearningsController < ApplicationController
  MAX_ENTRIES_PER_PAGE = 10

  before_action :authenticate_user!

  def index
    @learnings = current_user.learnings.order(created_at: :desc)

    # TODO: Refactor the below filters to the model code
    if params[:search].present?
      @learnings = @learnings.where("lesson ILIKE ?", "%#{params[:search]}%")
    end

    # Maintain your existing pagination if you're using it
    @learnings = @learnings.paginate(page: params[:page], per_page: MAX_ENTRIES_PER_PAGE)
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

  # rubocop:disable Metrics/AbcSize
  # TODO: come back and try to see later how to reduce the method size further
  def destroy
    @learning = Learning.find_by(id: params[:id])

    if @learning.destroy
      flash.now[:success] = t(".success")
      @learnings = current_user.learnings
      respond_to do |format|
        format.turbo_stream { render :destroy, status: :see_other }
        # Below code is useful when you have JS disable on the browser, then a normal HTML request is received
        # TODO: Add a relevant test for the same
        format.html { redirect_to learnings_index_path, status: :see_other, flash: { success: t(".success") } }
      end
    else
      # TODO: Come back to surely see that the code actually goes here through a relevant spec
      @learnings = current_user.learnings # TODO: Also just double check if we need this line for the else case
      flash.now[:error] = @learning.errors.full_messages
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

    def learnings_params
      params.require(:learning).permit(:lesson, :description, :public, :organization_id, learning_category_ids: [])
    end
end
