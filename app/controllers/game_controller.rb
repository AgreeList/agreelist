class GameController < ApplicationController
  before_action :load_individual

  def index
    @statements = []
    @individual.statements.order('RANDOM()').limit(10).each do |statement|
      @statements << {
        id: statement.id,
        content: statement.content
      }
    end
    @individual_attributes = @individual.attributes.slice("id", "name")
    @individual_attributes[:picture_url] = @individual.picture.url(:thumb)
  end

  private

  def load_individual
    @individual = Individual.where('lower(twitter) = ?', params[:id].downcase).first || Individual.find_by_hashed_id(params[:id].gsub("user-", ""))
  end
end
