class FollowsController < ApplicationController
  before_action :login_required
  before_action :find_statement, only: [:create, :destroy]
  before_action :admin_required, only: :index

  def index
    @followed_statements = followed_objects(Statement)
    @followed_individuals = followed_objects(Individual)
  end

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

  def followed_objects(class_name)
    follows = Follow.where(followable_type: class_name.to_s).group_by(&:followable_id)
    followed_statements = {}
    follows.each do |statement_id, follows|
      followed_statements[class_name.find(statement_id)] = follows.map{|f| Individual.find(f.follower_id)}
    end
    followed_statements = followed_statements.sort_by{|statement, individuals| - individuals.size}
  end
end
