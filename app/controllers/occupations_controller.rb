class OccupationsController < ApplicationController
  before_action :set_back_url_to_current_page, only: [:index, :show]

  def index
    @occupations = Individual.tag_counts_on(:occupations).sort_by{|t| - t.taggings_count}
    load_follows_people_ids
    load_occupations_and_schools(number: 7, min_count: 50)
  end

  def show
    @occupation = params[:id].gsub("-", " ")
    @agreements = Agreement.context("occupations", @occupation).order(updated_at: :desc).page(params[:page] || 1).per(50)
    load_follows_people_ids
    load_occupations_and_schools(number: 7, min_count: 50)
  end
end
