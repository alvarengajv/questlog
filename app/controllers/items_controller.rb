class ItemsController < ApplicationController
  before_action :require_authentication
  before_action :set_task_list
  before_action :set_item, only: [ :edit, :update, :destroy, :toggle, :move ]

  def edit
  end

  def create
    @item = @task_list.items.build(item_params)
    @item.position = (@task_list.items.maximum(:position) || 0) + 1

    @source = params[:source]

    if @item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @source == "board" ? task_lists_path : @task_list }
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
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { head :unprocessable_entity }
      end
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
      @gamification_result = GamificationService.item_completed!(current_user, @item)
    else
      @item.pending!
      @gamification_result = GamificationService::Result.new(xp_gained: 0, unlocked_achievements: [], leveled_up: false, new_level: nil)
    end

    @new_recurring_item = RecurrenceService.call(@item)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @task_list }
    end
  end

  def move
    target_list = current_user.task_lists.find(params[:target_task_list_id])
    position = (target_list.items.maximum(:position) || 0) + 1

    @source_list = @task_list
    @item.update!(task_list: target_list, position: position)
    @target_list = target_list

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to task_lists_path }
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
