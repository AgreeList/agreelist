class StatementsController < ApplicationController
  before_action :login_required, only: [:new, :create, :create_and_vote]
  before_action :admin_required, only: [:edit, :update, :destroy]
  before_action :find_statement, only: [:show, :destroy, :update, :edit, :occupations, :schools]
  before_action :find_related_statements, only: :show
  before_action :redirect_to_statement_url, only: :show
  before_action :set_back_url_to_current_page, only: [:show, :index]

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
      notify("new_statement", statement_id: @statement.id)
      redirect_to @statement
    else
      flash[:error] = @statement.errors.messages[:content].first
      render template: "static_pages/home"
    end
  end

  def create_and_vote # from new_question_path & from user profiles
    @statement = find_statement_by_content || Statement.new(content: params[:content], individual: current_user)
    new_record = @statement.id.nil?
    if @statement.save
      notify("new_statement", statement_id: @statement.id) if new_record
      agreement = Agreement.create(
        statement: @statement,
        individual_id: params[:individual_id] || current_user.id,
        reason: params[:reason],
        url: params[:url],
        extent: ((params[:commit] == "She/he agrees") ? 100 : 0))
      notify("new_agreement", agreement_id: agreement.id)
      notify("new_opinion", agreement_id: agreement.id) if agreement.reason.present?
      redirect_to(get_and_delete_back_url || new_path)
    else
      flash[:error] = @statement.errors.full_messages.first
      redirect_to new_path
    end
  end

  # GET /statements
  # GET /statements.json
  def index
    @statements = Statement.select("statements.id, statements.content, statements.url, count(agreements.id) as agreements_count").where("agreements.reason is not null and agreements.reason != ''").joins("left join agreements on statements.id=agreements.statement_id").group("statements.id").order("agreements_count DESC, statements.created_at ASC")
    @statements = @statements + Statement.select("id, content, url, 0 as agreements_count").where("id not in (select distinct statement_id from agreements)")
    if params[:order] == "followers"
      @statements = @statements.sort_by{|s| - s.followers.size}
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @statements }
    end
  end

  def deprecated_show
    hashed_id = params[:title_and_hashed_id].split("-").last
    statement = Statement.find_by_hashed_id(hashed_id)
    if statement
      redirect_to statement_path(statement)
    else
      redirect_to root_path, notice: "Page not found"
    end
  end

  # GET /statements/1
  # GET /statements/1.json
  def show
    add_meta_tags({
      title: @statement.content,
      description: "List of who does and who does not agree",
      picture_object: @statement
    })

    @filters = {}
    @filters[:include] = params[:include] || "opinions"
    @filters[:type] = params[:type] == "influencers" ? nil : params[:type]
    if params[:type] == nil && @statement.agreements.filter(@filters).size == 0
      @filters[:type] = "all"
    end
    @filters[:school] = params[:school] == "any" ? nil : params[:school]
    @filters[:occupation] = params[:occupation] == "any" ? nil : params[:occupation]
    if params[:v] == "agree & disagree" || params[:v] == "agree+%26+disagree"
      @filters[:v] = nil
    else
      @filters[:v] = params[:v]
    end
    @statement_filters = Statement.order(opinions_count: :desc).limit(12)

    if params[:c] == "Others"
      @agreements_in_favor = @statement.agreements_in_favor(order: params[:order], filter_by: :non_categorized)
      @agreements_against = @statement.agreements_against(order: params[:order], filter_by: :non_categorized)
    else
      category_id = ReasonCategory.find_by_name(params[:c]).try(:id)
      @agreements_in_favor = @statement.agreements_in_favor(order: params[:order], category_id: category_id)
      @agreements_against = @statement.agreements_against(order: params[:order], category_id: category_id)
    end
    @agreements_in_favor = @agreements_in_favor.filter(@filters)
    @agreements_against = @agreements_against.filter(@filters)
    supporters_count = @agreements_in_favor.size
    detractors_count = @agreements_against.size
    @agreements_count = supporters_count + detractors_count
    @percentage_in_favor = (supporters_count * 100.0 / @agreements_count).round if @agreements_count > 0

    @agreements_in_favor = @agreements_in_favor.page(params[:page]).per(30)
    @agreements_against = @agreements_against.page(params[:page] || 1).per(30)


    @comment = Comment.new
    @comments = {}
    @statement.comments.each{|comment| @comments[comment.individual.id] = comment}

    @categories = ReasonCategory.all
    @professions = Profession.all
    @admin = admin?
    @shortened_url_without_params = Rails.env.test? ? request.url : Shortener.new(full_url: request.base_url + request.path, object: @statement).get

    @new_user = Individual.new unless current_user

    load_occupations_and_schools(statement: @statement, number: 7, min_count: 1)
    @dropdown_occupations = OccupationsCache.new(statement: @statement).read.first(11)

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
    @statement = Statement.new(params.require(:statement).permit(:content).merge(individual_id: current_user.id))

    if @statement.save
      notify("new_statement", statement_id: @statement.id)
      redirect_to @statement, notice: 'Statement was successfully created'
    else
      render action: "new"
    end
  end

  # PUT /statements/1
  # PUT /statements/1.json
  def update
    respond_to do |format|
      if @statement.update_attributes(params.require(:statement).permit(:content, :description, :url, :tag_list, :picture_from_url))
        format.html { redirect_to(get_and_delete_back_url || statements_path, notice: 'Statement was successfully updated.') }
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
    @min_count = (params[:min] || 1).to_i
    @occupations_count = OccupationsTable.new(statement: @statement, min_count: @min_count).table
  end

  def schools
    @min_count = (params[:min] || 1).to_i
    @schools_count = SchoolsTable.new(statement: @statement, min_count: @min_count).table
  end

  private

  def find_statement
    url = params[:id]
    @statement = Statement.where(url: url).first || OldStatementUrl.where(url: url).first.try(:statement) || redirect_to(root_path, notice: "Page not found")
  end

  def redirect_to_statement_url
    redirect_to statement_path(@statement) if params[:id] != @statement.to_param
  end

  def find_related_statements
    tags = @statement.tag_list
    tags.delete("top")
    tag = tags.first
    tag = "top" if tag.nil? || tag == "none"
    @related_statements = Statement.where.not(id: @statement.id).tagged_with(tag).order(created_at: :desc).limit(6)
  end

  def find_statement_by_content
    Statement.where('lower(content) = ?', params[:content]).first
  end
end
