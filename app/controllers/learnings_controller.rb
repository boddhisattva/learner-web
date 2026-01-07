# frozen_string_literal: true

class LearningsController < ApplicationController
  before_action :authenticate_user!

  LEARNINGS_SEARCH_FRAME_ID = 'learnings_list'

  def index
    learnings_scope = current_user_learnings
                      .order(created_at: :desc)
    learnings_scope = learnings_scope.search(params[:query]) if params[:query].present?
    @pagy, @learnings = pagy(learnings_scope)

    @learnings_count = current_membership&.learnings_count || 0

    render_turbo_frame_response if turbo_frame_request?
  end

  def new
    @learning = Learning.new
    load_learning_categories
  end

  def create
    @learning = Learning.new(learnings_params)
    @learning.creator_id = current_user.id
    @learning.last_modifier_id = current_user.id
    load_learning_categories

    respond_to do |format|
      @learning.save ? handle_create_success(format) : handle_create_failure(format)
    end
  end

  def show
    @learning = current_user_learnings.includes(:categories).find_by(id: params[:id])

    if @learning.blank?
      redirect_to learnings_path, status: :see_other, flash: { error: t('.error') }
      return
    end

    return unless turbo_frame_request?

    render partial: 'learning', locals: { learning: @learning }
  end

  def edit
    @learning = current_user_learnings.find_by(id: params[:id])
    load_learning_categories

    if @learning.blank?
      redirect_to learnings_path, status: :see_other, flash: { error: t('.not_found') }
      return
    end

    # Turbo Frame requests need just the partial, not the full page
    return unless turbo_frame_request?

    render partial: 'form', locals: { learning: @learning, learning_categories: @learning_categories }
  end

  def update
    @learning = current_user_learnings.find_by(id: params[:id])
    return redirect_to learnings_path, status: :see_other, flash: { error: t('.not_found') } if @learning.blank?

    @learning.last_modifier_id = current_user.id

    @learning.update(learnings_params) ? handle_update_success : handle_update_failure
  end

  def destroy
    @learning = current_user_learnings.find_by(id: params[:id])
    return redirect_to learnings_path, status: :see_other, flash: { error: t('.not_found') } if @learning.blank?

    respond_to do |format|
      @learning.destroy ? handle_destroy_success(format) : handle_destroy_failure(format)
    end
  end

  def cancel
    @learning = current_user_learnings.find_by(id: params[:id])

    if @learning.blank?
      redirect_to learnings_path, status: :see_other, flash: { error: t('.not_found') }
      return
    end

    respond_to do |format|
      format.turbo_stream { render :cancel }
      format.html { redirect_to learning_path(@learning), status: :see_other }
    end
  end

  private

    def learnings_params
      params.require(:learning).permit(:lesson, :description, :public_visibility, :organization_id, category_ids: [])
    end

    def load_paginated_learnings(page = 1)
      @pagy, @learnings = pagy(current_user_learnings.order(created_at: :desc), page: page)
    end

    def load_learning_categories
      return @learning_categories = LearningCategory.none unless current_organization

      @learning_categories = LearningCategory
                             .where(organization_id: current_organization.id)
                             .order(created_at: :desc)
                             .limit(100)
    end

    def current_user_learnings
      return Learning.none unless current_organization

      current_user.learnings.where(organization_id: current_organization.id)
    end

    def render_turbo_frame_response
      if request.headers['Turbo-Frame'] == LEARNINGS_SEARCH_FRAME_ID
        render partial: 'learnings_list', locals: { learnings: @learnings, pagy: @pagy }
      else
        render partial: 'learnings_page', locals: { learnings: @learnings, pagy: @pagy }
      end
    end

    def handle_create_success(format)
      flash.now[:success] = t('.success', lesson: @learning.lesson)
      # Explicitly load page 1 after creating a new learning to see latest learnings first
      load_paginated_learnings(1)
      format.turbo_stream { render :create, status: :created }
      format.html do
        redirect_to learnings_path, status: :see_other, flash: { success: t('.success', lesson: @learning.lesson) }
      end
    end

    def handle_create_failure(format)
      format.turbo_stream { render :new, status: :unprocessable_entity }
      format.html do
        flash.now[:error] = @learning.errors.full_messages
        render :new, status: :unprocessable_entity
      end
    end

    def handle_update_success
      if turbo_frame_request?
        flash.now[:success] = t('.success', lesson: @learning.lesson)
        render :update, status: :ok
      else
        redirect_to learning_path(@learning),
                    status: :see_other,
                    flash: { success: t('.success', lesson: @learning.lesson) }
      end
    end

    def handle_update_failure
      load_learning_categories
      if turbo_frame_request?
        render partial: 'form',
               locals: { learning: @learning, learning_categories: @learning_categories },
               status: :unprocessable_entity
      else
        flash.now[:error] = @learning.errors.full_messages
        render :edit, status: :unprocessable_entity
      end
    end

    def handle_destroy_success(format)
      flash.now[:success] = t('.success', lesson: @learning.lesson)
      load_paginated_learnings
      format.turbo_stream { render :destroy, status: :see_other }
      format.html do
        redirect_to learnings_path, status: :see_other, flash: { success: t('.success', lesson: @learning.lesson) }
      end
    end

    def handle_destroy_failure(format)
      load_paginated_learnings
      flash.now[:error] = @learning.errors.full_messages
      format.turbo_stream { render :destroy, status: :see_other }
      format.html { redirect_to learnings_path, status: :see_other, flash: { error: @learning.errors.full_messages } }
    end
end
