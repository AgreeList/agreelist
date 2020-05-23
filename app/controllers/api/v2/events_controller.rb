module Api::V2
  class EventsController < ApiController
    def create
      Rails.logger.info "event:#{params[:name]} - #{current_user&.id} | #{anonymous_id} --------------------"
      vote if params[:name] == "vote" && current_user.present?
      track
      head :ok
    end

    private

    def vote
      agreement = Agreement.new(statement_id: params[:statement_id], individual: current_user, extent: params[:extent])
      unless agreement.save
        Rails.logger.error "Error saving agreement statement_id: #{params[:statement_id]}, individual: #{current_user.id}, extent: #{params[:extent]}"
      end
    end

    def track
      statement = Statement.find_by(id: params[:statement_id])
      game_individual = Individual.find_by(id: params[:game_individual_id])
      Analytics.track(
        user_id: current_user&.id,
        anonymous_id: anonymous_id,
        event: params[:name],
        properties: {
          statement: statement&.content,
          game_individual: game_individual&.visible_name,
          extent: params[:extent]
        }
      )
    end
  end
end
