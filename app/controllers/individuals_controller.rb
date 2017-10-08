class IndividualsController < ApplicationController
  before_action :login_required, only: [:edit, :update, :save_email]
  before_action :load_individual, except: [:save_email, :new, :create]
  before_action :has_update_individual_rights?, only: :update
  before_action :set_back_url_to_current_page, only: :show, if: :individual?
  include DelayedUpvote

  def new
    @individual = Individual.new
  end

  def create
    @individual = Individual.new(params.require(:individual).permit(:email, :password, :password_confirmation, :is_user))
    if @individual.save
      notify("sign_up", current_user_id: @individual.id)
      notify("subscribe") if params[:subscribed]
      @individual.send_activation_email
      session[:user_id] = @individual.id
      if params[:task] == "follow"
        statement_to_follow = Statement.find(params[:statement_id])
        @individual.follow(statement_to_follow)
        notify("follow", statement_id: statement_to_follow.id)
      end
      if params[:task] == "upvote" || params[:individual].try(:[], :task) == "upvote"
        upvote(redirect_to: edit_individual_path(@individual), agreement_id: params[:agreement_id] || params[:individual].try(:[], :agreement_id))
      else
        redirect_to edit_individual_path(@individual), notice: (params[:subscribed] ? "Subscribed" : nil)
      end
    else
      flash[:error] = @individual.errors.full_messages.join(". ")
      render action: :new
    end
  end

  def activation
    @individual = Individual.find_by_activation_digest(params[:id])
    if @individual
      @individual.activate
      redirect_to root_path, notice: "Your account has been activated"
    else
      flash[:notice] = "Error activating your account"
      redirect_to current_user ? root_path : login_path
    end
  end

  def show
    if @individual
      @school_list = @individual.school_list
      @occupation_list = @individual.occupation_list
      @agreements = @individual.agreements.joins(:statement).order("statements.opinions_count desc")
    else
      render action: "missing"
    end
  end

  def edit
    redirect_to root_path, notice: "Sorry, you don't have access to this" if !admin? && @individual != current_user
  end

  def update
    if @individual == current_user || admin?
      params[:individual][:name] = nil if params[:individual][:name] == ""
      whitelisted_params = [:name, :bio, :picture_from_url, :profession_id, :wikipedia]
      whitelisted_params = whitelisted_params + [:twitter, :email, :ranking] if admin?
      whitelisted_params = whitelisted_params + [:password, :password_confirmation] if @individual.password_digest.blank? && @individual == current_user
      result = @individual.update_attributes(params.require(:individual).permit(*whitelisted_params))
      if result
        respond_to do |format|
          format.json { render status: 200, json: @individual }
          format.html { redirect_to(get_and_delete_back_url || root_path, notice: 'Successfully updated.') }
        end
      else
        render action: "edit"
      end
    else
      redirect_to root_path, notice: "Sorry, you don't have access to this"
    end
  end

  def save_email
    if current_user.update_attributes(params.require(:individual).permit(:email))
      back = params[:back].try(:keys).try(:first)
      redirect_to back.try(:present?) ? back : root_path
    else
      render action: "edit"
    end
  end

  private

  def load_individual
    @individual = Individual.where('lower(twitter) = ?', params[:id].downcase).first || Individual.find_by_hashed_id(params[:id].gsub("user-", ""))
  end

  def individual?
    @individual.present?
  end
end
