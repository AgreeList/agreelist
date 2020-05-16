class GameController < ApplicationController
  def index
    @agreements = []
    Agreement.includes(:individual).order(upvotes_count: :desc).limit(3).each do |agreement|
      @agreements << {
        id: agreement.id,
        individual: { name: agreement.individual.name }
      }
    end
  end
end
