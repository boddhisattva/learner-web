# frozen_string_literal: true

class LearningsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_learning, only: %i[edit update destroy cancel]
  before_action :ensure_learning_exists!, only: %i[edit update destroy cancel]
  before_action :load_learning_categories, only: %i[new create edit]

  LEARNINGS_SEARCH_FRAME_ID = 'learnings_list'
  LEARNING_CATEGORY_LIMIT = 100

  def index
    learnings_scope = user_learnings_in_current_organization
                      .order(created_at: :desc)
    learnings_scope = learnings_scope.search(params[:query]) if params[:query].present?
    @pagy, @learnings = pagy(learnings_scope)

    @learnings_count = current_membership&.learnings_count || 0

    render_turbo_frame_response if turbo_frame_request?
  end

  def new
    @learning = Learning.new(organization_id: current_organization.id)
  end

  def create
    @learning = Learning.new(learnings_params)
    @learning.creator_id = current_user.id
    @learning.last_modifier_id = current_user.id
    @learning.organization_id = current_organization.id

    if @learning.save
      render_success_with_learnings_list(page: 1, status: :created, template: :create)
    else
      render_failure(template: :new)
    end
  end

  def show
    @learning = user_learnings_in_current_organization
                .includes(:categories, :creator, :last_modifier, :organization)
                .find_by(id: params[:id])

    redirect_to learnings_path, status: :see_other, flash: { error: t('learnings.not_found') } if @learning.blank?
  end

  def edit
    respond_to do |format|
      format.html do
        render partial: 'form', locals: { learning: @learning, learning_categories: @learning_categories } if turbo_frame_request?
      end
    end
  end

  def update
    prepare_learning_for_update

    if @learning.update(learnings_params)
      if turbo_frame_request?
        flash.now[:success] = t('.success', lesson: @learning.lesson)
        render :update, status: :ok
      else
        redirect_to learning_path(@learning),
                    status: :see_other,
                    flash: { success: t('.success', lesson: @learning.lesson) }
      end
    else
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
  end

  def destroy
    if @learning.destroy
      render_success_with_learnings_list(status: :see_other, template: :destroy)
    else
      load_paginated_learnings
      flash.now[:error] = @learning.errors.full_messages

      respond_to do |format|
        format.turbo_stream { render :destroy, status: :see_other }
        format.html { redirect_to learnings_path, status: :see_other, flash: { error: @learning.errors.full_messages } }
      end
    end
  end

  def cancel
    respond_to do |format|
      format.turbo_stream { render :cancel }
      format.html { redirect_to learning_path(@learning), status: :see_other }
    end
  end

  private

    def learnings_params
      params.require(:learning).permit(:lesson, :description, :public_visibility, category_ids: [])
    end

    def load_paginated_learnings(page = 1)
      @pagy, @learnings = pagy(user_learnings_in_current_organization.order(created_at: :desc), page: page)
    end

    def load_learning_categories
      return @learning_categories = LearningCategory.none unless current_organization

      @learning_categories = LearningCategory
                             .where(organization_id: current_organization.id)
                             .order(created_at: :desc)
                             .limit(LEARNING_CATEGORY_LIMIT)
    end

    def user_learnings_in_current_organization
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

    def render_success_with_learnings_list(status:, template:, page: nil)
      flash.now[:success] = t('.success', lesson: @learning.lesson)
      load_paginated_learnings(page)

      respond_to do |format|
        format.turbo_stream { render template, status: status }
        format.html do
          redirect_to learnings_path, status: :see_other, flash: { success: t('.success', lesson: @learning.lesson) }
        end
      end
    end

    def render_failure(template:)
      respond_to do |format|
        format.turbo_stream { render template, status: :unprocessable_entity }
        format.html do
          flash.now[:error] = @learning.errors.full_messages
          render template, status: :unprocessable_entity
        end
      end
    end

    def prepare_learning_for_update
      @learning.last_modifier_id = current_user.id
      @learning.organization_id = current_organization.id
    end

    def set_learning
      @learning = user_learnings_in_current_organization.find_by(id: params[:id])
    end

    def ensure_learning_exists!
      return if @learning.present?

      redirect_to learnings_path, status: :see_other, flash: { error: t('learnings.not_found') }
    end
end
