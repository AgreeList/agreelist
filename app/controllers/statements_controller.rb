class StatementsController < ApplicationController
  before_action :login_required, only: [:create, :create_and_agree]
  before_action :admin_required, only: [:edit, :update, :destroy, :index]
  before_action :find_statement, only: [:show, :destroy, :update, :edit, :occupations, :educated_at]
  before_action :redirect_to_statement_url, only: :show

  def quick_create
    @statement = Statement.new(content: params[:question])
    @statement.tag_list = "Others"
    if @statement.save
      if current_user
        unless current_user.email.present?
          current_user.email = params[:email]
          current_user.save
        end
      else
        Individual.find_or_create(email: params[:email])
      end
      LogMailer.log_email("@#{params[:email]} has created '#{@statement.content}'").deliver
      redirect_to @statement
    else
      flash[:error] = @statement.errors.messages[:content].first
      render template: "static_pages/home"
    end
  end

  def create_and_agree # from new_question_path & from user profiles
    @statement = Statement.new(content: params[:content], individual: current_user)

    LogMailer.log_email("@#{current_user.twitter} has created '#{@statement.content}'").deliver
    if @statement.save
      Agreement.create(
        statement: @statement,
        individual_id: params[:individual_id] || current_user.id,
        url: params[:url],
        extent: 100)
      redirect_to params[:back_url] || new_path
    else
      flash[:error] = @statement.errors.full_messages.first
      redirect_to new_path
    end
  end

  # GET /statements
  # GET /statements.json
  def index
    @statements = Statement.order("created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @statements }
    end
  end

  # GET /statements/1
  # GET /statements/1.json
  def show
    if params[:c] == "Others"
      @agreements_in_favor = @statement.agreements_in_favor(order: params[:order], filter_by: :non_categorized, profession: params[:profession], occupation: params[:occupation], page: params[:page])
      @agreements_against = @statement.agreements_against(order: params[:order], filter_by: :non_categorized, profession: params[:profession], occupation: params[:occupation], page: params[:page])
    else
      category_id = ReasonCategory.find_by_name(params[:c]).try(:id)
      @agreements_in_favor = @statement.agreements_in_favor(order: params[:order], category_id: category_id, profession: params[:profession], occupation: params[:occupation], page: params[:page])
      @agreements_against = @statement.agreements_against(order: params[:order], category_id: category_id, profession: params[:profession], occupation: params[:occupation], page: params[:page])
    end
    supporters_count = @statement.supporters_count(profession: params[:profession], occupation: params[:occupation])
    detractors_count = @statement.detractors_count(profession: params[:profession], occupation: params[:occupation])
    @agreements_count = supporters_count + detractors_count
    @percentage_in_favor = (supporters_count * 100.0 / @agreements_count).round if @agreements_count > 0
    @related_statements = Statement.where.not(id: @statement.id).tagged_with(@statement.tags.first).limit(6)

    @comment = Comment.new
    @comments = {}
    @statement.comments.each{|comment| @comments[comment.individual.id] = comment}

    @categories = ReasonCategory.all
    @professions = Profession.all

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @statement }
    end
  end

  # GET /statements/new
  # GET /statements/new.json
  def new
    @statement = Statement.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @statement }
    end
  end

  # GET /statements/1/edit
  def edit
  end

  # POST /statements
  # POST /statements.json
  def create
    @statement = Statement.new(params.require(:statement).permit(:content))

    if @statement.save
      redirect_to @statement, notice: 'Statement was successfully created'
    else
      render action: "new"
    end
  end

  # PUT /statements/1
  # PUT /statements/1.json
  def update
    respond_to do |format|
      if @statement.update_attributes(params.require(:statement).permit(:content))
        format.html { redirect_to edit_statement_path(Statement.where("id > #{@statement.id}").first), notice: 'Statement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /statements/1
  # DELETE /statements/1.json
  def destroy
    @statement.destroy

    respond_to do |format|
      format.html { redirect_to statements_url }
      format.json { head :no_content }
    end
  end

  def occupations
    @occupations_count = OccupationsTable.new(statement: @statement, min_count: 25).table
  end

  def educated_at
    @schools_count = SchoolsTable.new(statement: @statement, min_count: 10).table
  end

  private

  def find_statement
    @statement = Statement.find_by_hashed_id(params[:id].split("-").last)
  end

  def redirect_to_statement_url
    redirect_to statement_path(@statement) if params[:id] != @statement.to_param
  end
end
