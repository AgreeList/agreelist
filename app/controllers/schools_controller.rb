class SchoolsController < ApplicationController
  before_action :set_back_url_to_current_page, only: [:index, :show]

  def index
    @schools = Individual.tag_counts_on(:schools).sort_by{|t| - t.taggings_count}
    load_occupations_and_schools(number: 7, min_count: 50)
  end

  def show
    @school = params[:id].gsub("-", " ")
    @agreements = Agreement.context("schools", @school).order("case when (agreements.reason is not null and agreements.reason != '') THEN 1 END ASC, case when agreements.reason is null THEN 0 END ASC").order(updated_at: :desc).page(params[:page] || 1).per(50)
    load_occupations_and_schools(number: 7, min_count: 50)
  end
end
