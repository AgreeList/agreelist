class FollowsController < ApplicationController
  before_action :login_required
  before_action :find_statement

  def create
    current_user.follow(@object)
    notify("follow", args)
    redirect_to(get_and_delete_back_url || statement_path(@object))
  end

  def destroy
    current_user.stop_following(@object)
    notify("unfollow", args)
    redirect_to(get_and_delete_back_url || statement_path(@object))
  end

  private

  def find_statement
    if params[:statement_id]
      @object = Statement.find(params[:statement_id])
    elsif params[:individual_id]
      @object = Individual.find(params[:individual_id])
    end
  end

  def args
    if params[:statement_id]
      { statement_id: params[:statement_id] }
    elsif params[:individual_id]
      { individual_id: params[:individual_id] }
    end
  end
end
