class AgreementPositionsController < ApplicationController
  before_action :find_agreement
  before_action :insert_at, except: :destroy

  def top
    @agreement.move_to_top
    redirect_to get_and_delete_back_url || root_path, notice: "Done"
  end

  def bottom
    @agreement.move_to_bottom
    redirect_to get_and_delete_back_url || root_path, notice: "Done"
  end

  def higher
    @agreement.move_higher
    redirect_to get_and_delete_back_url || root_path, notice: "Done"
  end

  def lower
    @agreement.move_lower
    redirect_to get_and_delete_back_url || root_path, notice: "Done"
  end

  def destroy
    @agreement.remove_from_list if @agreement.position.present?
    redirect_to get_and_delete_back_url || root_path, notice: "Done"
  end

  private

  def insert_at
    @agreement.insert_at if @agreement.position.nil?
  end

  def find_agreement
    @agreement = Agreement.find_by_hashed_id(params[:id])
  end
end
