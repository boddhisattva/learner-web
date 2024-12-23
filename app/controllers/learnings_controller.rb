# frozen_string_literal: true

class LearningsController < ApplicationController
  before_action :authenticate_user!

  def index
    @learnings = current_user.learnings.order(created_at: :desc)
    # TO DO: Add pagination later
  end

  def new
    @learning = Learning.new
    @learning_categories = LearningCategory.all
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @learning = Learning.new(learnings_params)
    @learning.creator_id = current_user.id
    @learning.last_modifier_id = current_user.id

    if @learning.save
      redirect_to learnings_index_path,
                  status: :see_other,
                  flash: { success: t('.success', lesson: @learning.lesson) }
    else
      @learning_categories = LearningCategory.all
      flash.now[:error] = @learning.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  def show
    @learning = Learning.find_by(id: params[:id])

    return if @learning.present?

    redirect_to learnings_path, status: :see_other, flash: { error: t('.error') }
  end

  def edit
    @learning = Learning.find_by(id: params[:id])
    @learning_categories = LearningCategory.all

    redirect_to learnings_path, status: :see_other, flash: { error: t('.not_found') } if @learning.blank?
  end

  # rubocop:disable Metrics/AbcSize
  def update
    @learning = Learning.find_by(id: params[:id])
    return redirect_to learnings_path, status: :see_other, flash: { error: t('.not_found') } if @learning.blank?

    @learning.last_modifier_id = current_user.id

    if @learning.update(learnings_params)
      redirect_to learning_path(@learning),
                  status: :see_other,
                  flash: { success: t('.success', lesson: @learning.lesson) }
    else
      @learning_categories = LearningCategory.all
      flash.now[:error] = @learning.errors.full_messages
      render :edit, status: :unprocessable_entity
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
      @learnings = current_user.learnings
      respond_to do |format|
        format.turbo_stream { render :destroy, status: :see_other }
        # Below code is useful when you have JS disable on the browser, then a normal HTML request is received
        format.html { redirect_to learnings_index_path, status: :see_other, flash: { success: t('.success') } }
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
      params.require(:learning).permit(:lesson, :description, :public_visibility, :organization_id, learning_category_ids: [])
    end
end
