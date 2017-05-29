class SessionsController < ApplicationController
  include DelayedUpvote
  def new
  end

  def create
    if individual.try(:authenticate, params[:password])
      session[:user_id] = individual.id
      if params["task"] == "upvote"
        upvote(redirect_to: get_and_delete_back_url, agreement_id: params[:agreement_id])
      else
        redirect_to(get_and_delete_back_url || root_url, :notice => "Logged in!")
      end
    else
      flash.now[:error] = "Invalid email or password"
      render "new"
    end
  end

  def create_with_twitter
    auth = request.env["omniauth.auth"]
    user = Individual.find_by_twitter(auth["info"]["nickname"].downcase) || Individual.create_with_omniauth(auth)
    session[:user_id] = user.id
    LogMailer.log_email("#{user.name} (@#{user.twitter}) just signed in!").deliver
    if params["task"] == "voting"
      vote(user)
    elsif params["task"] == "post"
      create_statement_and_agree(user)
    elsif params["task"] == "upvote"
      upvote(redirect_to: get_and_delete_back_url, agreement_id: params[:agreement_id])
    else
      redirect_to(get_and_delete_back_url || root_path, notice: "Signed in!")
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to(get_and_delete_back_url || root_path, :notice => "Thanks for stopping by. See you soon!")
  end

  private

  def vote(user)
    vote = Vote.new(
      statement_id: params["statement_id"],
      individual_id: user.id,
      extent: params["vote"] == "agree" ? 100 : 0
    ).vote!
    redirect_to(edit_reason_path(vote))
  end

  def create_statement_and_agree(user)
    s = Statement.create(content: params["content"], individual_id: user.id)
    Vote.new(
      statement_id: s.id,
      individual_id: user.id,
      extent: 100
    ).vote!
    redirect_to(get_and_delete_back_url || root_path, notice: "Signed in!")
  end

  def individual
    Individual.find_by_email(params[:email]) if params[:email].present?
  end
end
