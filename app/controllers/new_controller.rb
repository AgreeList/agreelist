class NewController < ApplicationController
  before_action :set_back_url_to_current_page, only: :index
  before_action :replace_page_type, only: :index
  def index
    add_meta_tags({
      title: "Tracking influencers' opinions",
      description: "Non-profit aiming to fight misinformation and improve the quality of debates by showing what people think and why, on both sides of key issues",
    })
    default_min_count = 50
    @filters = {}
    @filters[:type] = params[:type] == "influencers" ? nil : params[:type]
    @filters[:school] = params[:school] == "any" ? nil : params[:school]
    @filters[:occupation] = params[:occupation] == "any" ? nil : params[:occupation]
    @filters[:min_count] = params[:min_count] == default_min_count.to_s ? nil : params[:min_count]
    @filters[:statement] = params[:statement] == "any" ? nil : params[:statement]
    if @filters[:statement]
      s = Statement.find_by_content(@filters[:statement])
      redirect_to statement_path(s)
    end
    @filters[:v] = params[:v] == "agree & disagree" || params[:v] == "agree+%26+disagree" ? nil : params[:v]
    @statement_filters = Statement.order(opinions_count: :desc).limit(12)
    load_occupations_and_schools(number: 7, min_count: @filters[:min_count] || default_min_count)
    @agreements = Agreement.filter(@filters, current_user).order(updated_at: :desc).page(params[:page] || 1).per(50).includes(:statement).includes(:individual)
    @new_user = Individual.new unless current_user
    @statement = Statement.new
  end

  def vote
    agreement = Agreement.where(statement_id: params[:statement_id], individual_id: current_user.id).first
    if agreement
      agreement.extent = extent
    else
      agreement = Agreement.new(
        statement_id: params[:statement_id],
        individual_id: current_user.id,
        extent: params[:vote] == "agree" ? 100 : 0)
    end
    if agreement.save
      notify("new_agreement")
    end
    redirect_to edit_reason_path(agreement) || new_path
  end

  private

  def extent
    params[:vote] == "agree" ? 100 : 0
  end

  def replace_page_type
    @page_type = 'home'
  end
end
