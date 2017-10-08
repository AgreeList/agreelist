class VotesController < ApplicationController
  def create
    return false unless current_user
    agreement = Agreement.create(
      statement_id: params[:statement_id],
      extent: params[:add] == "agreement" ? 100 : 0,
      individual: current_user
    )
    notify("new_agreement", agreement_id: agreement.id)
  end

  private

  def statement
    Statement.find(params[:statement_id])
  end
end
