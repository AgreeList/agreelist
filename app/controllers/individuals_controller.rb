class IndividualsController < ApplicationController
  before_action :login_required, only: [:edit, :update, :save_email]
  before_action :load_individual, except: [:save_email, :new, :create]
  before_action :has_update_individual_rights?, only: :update
  before_action :set_back_url_to_current_page, only: :show, if: :individual?
  include DelayedUpvote

  def new
    @individual = Individual.new
  end

  def search
    render json: Individual.where("name ILIKE ?", "%#{params[:term]}%").order(followers_count: :desc).limit(10).to_json(methods: [:mini_picture_url])
  end

  def create
    if params[:source] == 'game'
      create_from_game
    else
      @individual = Individual.new(params.require(:individual).permit(:email, :password, :password_confirmation, :is_user))
      if (Rails.env.test? || verify_recaptcha(model: @individual)) && @individual.save
        notify("sign_up", current_user_id: @individual.id)
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
          redirect_to(get_and_delete_back_url || root_path, notice: "Welcome to Agreelist!")
        end
      else
        flash[:error] = @individual.errors.full_messages.join(". ")
        render action: :new
      end
    end
  end

  def activation
    @individual = Individual.find_by_activation_digest(params[:id])
    if @individual
      @individual.activate
      session[:user_id] = @individual.id
      redirect_to root_path, notice: "Your account has been activated"
    else
      flash[:error] = "Error activating your account"
      redirect_to current_user ? root_path : login_path
    end
  end

  def show
    if @individual
      add_meta_tags({
        title: @individual.name,
        description: "Opinions from #{@individual.name} and lists of who does and who does not agree",
        picture_object: @individual
      })
      @school_list = @individual.school_list
      @occupation_list = @individual.occupation_list
      prepare_game unless params[:all]
      @agreements = params[:all] || @agreements_game.empty? ? @agreements = @individual.agreements.joins(:statement).order("statements.opinions_count desc") : []
      @disable_jquery = true
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
      whitelisted_params = whitelisted_params + [:twitter, :email, :ranking, :bio_link] if admin?
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

  def prepare_game
    @agreements_game = prepare_agreements_game
    @individual_attributes = @individual.attributes.slice("id", "name")
    @individual_attributes[:picture_url] = @individual.picture.url(:thumb)
    @individual_attributes[:url] = individual_path(@individual)
  end

  def prepare_agreements_game
    agreements = @individual.agreements.includes(:statement).order('RANDOM()').
      where("reason is not null and reason != ''")
    agreements = agreements.where.not(statement_id: current_user.agreements.pluck(:statement_id)) if current_user && params[:ask_again] != "true"
    agreements = agreements.map do |agreement|
      {
        id: agreement.id,
        extent: agreement.extent,
        reason: agreement.reason,
        statement: {
          id: agreement.statement_id,
          content: agreement.statement.content
        }
      }
    end
  end

  def create_from_game
    individual = Individual.new(email: params[:email])
    if params[:email].present? && individual.save
      session[:user_id] = individual.id
      track(individual)
      save_agreements(individual)
      from_individual = Individual.find(params[:from_individual_id])
      redirect_to individual_path(from_individual)
    else
      Rails.logger.debug("Error signing up: #{individual.errors.full_messages.join('. ')}")
      flash[:error] = "Invalid email"
      redirect_to signup_path
    end
  end

  def save_agreements(individual)
    agreements = JSON.load(params[:agreements]) if params[:agreements]
    agreements.each do |agreement|
      a = individual.agreements.new(statement_id: agreement['statement_id'], extent: agreement['extent'], individual: individual)
      unless a.save
        Rails.logger.error("Error saving agreement. Individual id: #{individual.id}. extent: #{agreement.extent}. statement id: #{agreement.statement_id}")
      end
    end
  end

  def track(individual)
    Analytics.track(
      user_id: individual.id,
      anonymous_id: anonymous_id,
      event: 'Sign up',
      properties: {
        source: params[:source]
      }
    )
  end
end
