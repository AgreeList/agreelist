class CommentsController < ApplicationController
  def create
    @comment = Comment.new(
      text: params[:comment][:text],
      individual_id: individual_id,
      statement_id: params[:statement_id],
      source: params[:comment_source])
    if @comment.save
      redirect_to statement_path(statement), notice: "Your comment has been created."
    else
      redirect_to statement_path(statement), notice: "There was an error. Please try again later and be sure that the user @#{twitter_username} exists on Twitter."
    end
  end

  private

  def individual_id
    begin
      Individual.find_by_twitter(twitter_username).id
    rescue
      nil
    end
  end

  def statement
    @statement ||= Statement.find(params[:statement_id])
  end

  def twitter_username
    @twitter_username ||= params[:twitter].present? ? params[:twitter].gsub("@", "") : current_user.twitter
  end
end
