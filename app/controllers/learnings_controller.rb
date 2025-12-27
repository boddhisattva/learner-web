# frozen_string_literal: true

class LearningsController < ApplicationController
  before_action :authenticate_user!

  def index
    @pagy, @learnings = pagy(current_user.learnings.order(created_at: :desc))

    render partial: 'learnings_page', locals: { learnings: @learnings, pagy: @pagy } if turbo_frame_request?
  end

  def new
    @learning = Learning.new
    @learning_categories = LearningCategory.all # TODO: See if this can benefit from pagination as '.all' can be a resource intensive operation
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @learning = Learning.new(learnings_params)
    @learning.creator_id = current_user.id
    @learning.last_modifier_id = current_user.id
    @learning_categories = LearningCategory.all # TODO: See if this can benefit from pagination as '.all' can be a resource intensive operation

    respond_to do |format|
      if @learning.save
        flash.now[:success] = t('.success')
        # Explicitly load page 1 after creating a new learning to see latest learnings first
        @pagy, @learnings = pagy(current_user.learnings.order(created_at: :desc), page: 1)
        format.turbo_stream { render :create, status: :created }
        format.html do
          redirect_to learnings_index_path, status: :see_other, flash: { success: t('.success') }
        end
      else
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity, flash: { error: @learning.errors.full_messages } }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def show
    @learning = Learning.find_by(id: params[:id])

    if @learning.blank?
      redirect_to learnings_path, status: :see_other, flash: { error: t('.error') }
      return
    end

    return unless turbo_frame_request?

    render partial: 'learning', locals: { learning: @learning }
    nil

    # Non-turbo requests: Rails automatically renders show.html.erb
    # This happens when users navigate directly to the show page (not via Turbo Frame)
  end

  def edit
    @learning = Learning.find_by(id: params[:id])
    @learning_categories = LearningCategory.all

    if @learning.blank?
      redirect_to learnings_path, status: :see_other, flash: { error: t('.not_found') }
      return
    end

    # Turbo Frame requests need just the partial, not the full page
    return unless turbo_frame_request?

    render partial: 'form', locals: { learning: @learning, learning_categories: @learning_categories }

    # Otherwise render edit.html.erb (full page for non-turbo browsers)
  end

  # rubocop:disable Metrics/AbcSize
  def update
    @learning = Learning.find_by(id: params[:id])
    return redirect_to learnings_path, status: :see_other, flash: { error: t('.not_found') } if @learning.blank?

    @learning.last_modifier_id = current_user.id

    if @learning.update(learnings_params)
      if turbo_frame_request?
        # For Turbo Frames, just render the partial - Turbo will replace the frame content
        render partial: 'learning',
               locals: { learning: @learning }
      else
        redirect_to learning_path(@learning),
                    status: :see_other,
                    flash: { success: t('.success') }
      end
    else
      @learning_categories = LearningCategory.all
      if turbo_frame_request?
        render partial: 'form',
               locals: { learning: @learning, learning_categories: @learning_categories },
               status: :unprocessable_entity
      else
        flash.now[:error] = @learning.errors.full_messages
        render :edit, status: :unprocessable_entity
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # TODO: come back and try to see later how to reduce the method size further
  def destroy
    @learning = Learning.find_by(id: params[:id])
    return redirect_to learnings_index_path, status: :see_other, flash: { error: t('.not_found') } if @learning.blank?

    if @learning.destroy
      flash.now[:success] = t('.success')
      # Explicitly load page 1 after deleting helps preserving nested infinite scroll structure on learnings index
      @pagy, @learnings = pagy(current_user.learnings.order(created_at: :desc))
      respond_to do |format|
        format.turbo_stream { render :destroy, status: :see_other }
        # Below code is useful when you have JS disable on the browser, then a normal HTML request is received
        format.html { redirect_to learnings_index_path, status: :see_other, flash: { success: t('.success') } }
      end
    else
      # Explicitly load page 1 on error helps preserving nested infinite scroll structure on learnings index
      @pagy, @learnings = pagy(current_user.learnings.order(created_at: :desc))
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
      params.require(:learning).permit(:lesson, :description, :public_visibility, :organization_id, learning_category_ids: [])
    end
end
