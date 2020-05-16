class GameController < ApplicationController
  def index
    @statements = []
    Statement.order(opinions_count: :desc).limit(10).each do |statement|
      @statements << {
        id: statement.id,
        content: statement.content
      }
    end
  end
end
