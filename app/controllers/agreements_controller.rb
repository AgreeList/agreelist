class AgreementsController < ApplicationController
  before_action :admin_required, only: [:destroy, :touch]
  before_action :find_agreement, only: [:upvote, :update, :touch, :destroy]
  before_action :set_back_url_to_current_page, only: :show
  before_action :check_if_spam, only: :create

  def new
    @statement = Statement.find_by_url(params[:s])
    if params[:name].blank? || params[:opinion].blank?
      flash[:error] = "Name and opinion can't be blank"
      redirect_to statement_path(@statement)
    end
    @individual = Individual.where(name: params[:name]).first || Individual.new(name: params[:name].strip)
    @opinion, @source = params[:opinion].scan(/\A(.*)(http[^\ ]*\Z)/).first || [params[:opinion].strip, nil]
    notify('pre_new_opinion', statement: @statement.content, name: params[:name], opinion: params[:opinion])
  end

  def create
    @statement = Statement.find(params[:statement_id])
    voter = find_or_create_voter!
    agreement = cast_vote(voter)
    notify('new_agreement', agreement_id: agreement.id)
    notify('new_opinion', agreement_id: agreement.id) if agreement.reason.present?
    expire_fragment "brexit_board" if @statement.brexit?
    session[:added_voter] = voter.hashed_id if voter.twitter.present?
    redirect_to statement_path(@statement, type: "all", order: "recent"), notice: "The opinion has been added"
  end

  def upvote
    if upvote = Upvote.where(agreement: @agreement, individual: current_user).first
      upvote.destroy
      flash[:notice] = "Upvote removed!"
    else
      upvote = Upvote.create(agreement: @agreement, individual: current_user)
      notify('upvote', upvote_id: upvote.id)
      flash[:notice] = "Upvoted!"
    end
    @agreement.update_attribute(:upvotes_count, @agreement.upvotes.count)
    redirect_to statement_path(@agreement.statement)
  end

  def update
    if @agreement.individual == current_user || admin?
      notify('new_opinion', agreement_id: @agreement.id) if @agreement.reason.blank? && params[:agreement][:reason].present?
      @agreement.update_attributes(params[:agreement].permit(:reason, :url, :hashed_id, :reason_category_id ))
      respond_to do |format|
        format.html { redirect_to(get_and_delete_back_url || statement_path(@agreement.statement)) }
        format.js { render json: @agreement.to_json, status: :ok }
      end
    else
      redirect_to(get_and_delete_back_url || root_path, notice: "Access denied")
    end
  end

  def touch
    @agreement.touch if @agreement
    redirect_to(get_and_delete_back_url || root_path)
  end

  def destroy
    statement = @agreement.statement
    @agreement.destroy
    redirect_to(get_and_delete_back_url || statement_path(statement))
  end

  def show
    @agreement = Agreement.find_by_hashed_id(params[:id])
    @agreement_comment = AgreementComment.new
  end

  private

  def find_or_create_voter!
    Voter.new(
      name: params[:name].try(:strip),
      twitter: twitter,
      profession_id: params[:profession_id],
      current_user: current_user,
      wikipedia: params[:wikipedia],
      bio: params[:biography],
      picture: params[:picture_from_url]
    ).find_or_create!
  end

  def cast_vote(voter)
    Agreement.create(
      statement_id: params[:statement_id],
      individual_id: voter.id,
      url: params[:source],
      reason: params[:comment].present? ? params[:comment] : nil,
      reason_category_id: params[:reason_category_id],
      extent: params[:commit] == "She/he disagrees" ? 0 : 100,
      added_by_id: added_by_id(params[:email].try(:strip)).try(:id)
    )
  end

  def twitter
    @twitter ||= params[:twitter].try(:downcase).try(:strip).gsub(/\A@/, '')
  end

  def check_if_spam
    if spam?
      render status: 401, plain: "Your message has to be approved because it seemed spam. Sorry for the inconvenience."
      LogMailer.log_email("spam? params: #{params.inspect}").deliver #unless statement_used_by_spammers?
    end
  end

  def spam? # real people have name and surname separated by a space
    current_user.nil? && !twitter? && !first_and_surname?
  end

  def twitter?
    params[:name][0] == "@" || (params[:name][0..19] == "https://twitter.com/")
  end

  def first_and_surname?
    params[:name] =~ /\ /
  end

  def statement_used_by_spammers?
    params[:statement_id] == "113"
  end

  def find_agreement
    @agreement = Agreement.find_by_hashed_id(params[:id])
  end

  def added_by_id(email)
    if current_user
      current_user
    elsif email.present?
      Individual.find_by_email(email) || Individual.create(email: email)
    end
  end
end
