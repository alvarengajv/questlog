class ItemsController < ApplicationController
  before_action :require_authentication
  before_action :set_task_list
  before_action :set_item, only: [:update, :destroy, :toggle, :sort]

  def create
    @item = @task_list.items.build(item_params)
    @item.position = (@task_list.items.maximum(:position) || 0) + 1

    if @item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @task_list }
      end
    else
      head :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @task_list }
      end
    else
      head :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @task_list }
    end
  end

  def toggle
    if @item.pending?
      @item.completed!
      GamificationService.item_completed!(current_user, @item)
    else
      @item.pending!
    end

    RecurrenceService.process!(@item)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @task_list }
    end
  end

  def sort
    if params[:item_ids].present? && params[:item_ids].is_a?(Array)
      Item.transaction do
        params[:item_ids].each_with_index do |id, index|
          @task_list.items.where(id: id).update_all(position: index + 1)
        end
      end
    end
    head :ok
  end

  private

  def set_task_list
    @task_list = current_user.task_lists.find(params[:task_list_id])
  end

  def set_item
    @item = @task_list.items.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:content, :priority, :due_date, :recurrence)
  end
end
