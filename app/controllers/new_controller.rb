class NewController < ApplicationController
  before_action :set_back_url_to_current_page, only: :index
  before_action :replace_page_type, only: :index
  def index
    add_meta_tags({
      title: "Tracking influencers' opinions",
      description: "Non-profit aiming to fight misinformation and improve the quality of debates by showing what people think and why, on both sides of key issues",
    })
    if current_user.present?
      follows_people_ids = current_user.follows.where(followable_type: "Individual").map{|i| i.followable_id}
      @agreements = Agreement.where(added_by_id: follows_people_ids).or(Agreement.where(individual_id: follows_people_ids)).order(created_at: :desc).page(params[:page] || 1).per(50).includes(:statement).includes(:individual)
    else
      @agreements = Agreement.joins("left join individuals on individuals.id=agreements.individual_id").where("individuals.wikipedia is not null and individuals.wikipedia != ''").order(updated_at: :desc).page(params[:page] || 1).per(50).includes(:statement).includes(:individual)
      @new_user = Individual.new
    end
    @statement = Statement.new
    load_occupations_and_schools(number: 7, min_count: 50)
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
