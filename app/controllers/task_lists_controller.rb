class TaskListsController < ApplicationController
  before_action :require_authentication
  before_action :set_task_list, only: [:show, :update, :destroy, :archive, :restore]

  rescue_from ActiveRecord::RecordNotFound do
    head :not_found
  end

  def index
    @active_lists = current_user.task_lists.active.includes(:items).order(created_at: :desc)
    @archived_lists = current_user.task_lists.archived.order(created_at: :desc)

    if params[:search].present?
      @active_lists = @active_lists.search(params[:search])
      @archived_lists = @archived_lists.search(params[:search])
    end
  end

  def show
    @pending_items = @task_list.items.pending.order(due_date: :asc, priority: :desc)
    @completed_items = @task_list.items.completed.order(updated_at: :desc)
  end

  def create
    @task_list = current_user.task_lists.build(task_list_params)

    if @task_list.save
      respond_to do |format|
        format.html { redirect_to task_lists_path, notice: "Lista criada com sucesso." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.prepend("task_lists", partial: "task_lists/board_column", locals: { task_list: @task_list })
        end
      end
    else
      respond_to do |format|
        format.html { render :index, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("new_task_list_form", partial: "task_lists/form", locals: { task_list: @task_list }), status: :unprocessable_entity
        end
      end
    end
  end

  def update
    if @task_list.update(task_list_params)
      respond_to do |format|
        format.html { redirect_to task_lists_path, notice: "Lista atualizada." }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(@task_list, partial: "task_lists/board_column", locals: { task_list: @task_list })
        end
      end
    else
      respond_to do |format|
        format.html { render :index, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("task_list_#{@task_list.id}_form", partial: "task_lists/form", locals: { task_list: @task_list }), status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @task_list.destroy
    respond_to do |format|
      format.html { redirect_to task_lists_path, notice: "Lista removida." }
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(@task_list)
      end
    end
  end

  def archive
    @task_list.update(status: :archived)
    respond_to do |format|
      format.html { redirect_to task_lists_path, notice: "Lista arquivada." }
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(@task_list)
      end
    end
  end

  def restore
    @task_list.update(status: :active)
    respond_to do |format|
      format.html { redirect_to task_lists_path, notice: "Lista restaurada." }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@task_list),
          turbo_stream.prepend("task_lists", partial: "task_lists/board_column", locals: { task_list: @task_list })
        ]
      end
    end
  end

  private

  def set_task_list
    @task_list = current_user.task_lists.find(params[:id])
  end

  def task_list_params
    params.require(:task_list).permit(:title, :color)
  end
end
