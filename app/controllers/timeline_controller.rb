class TimelineController < ApplicationController
  def index
    # user = current_user
    user = Individual.find_by_name("Ben Dixon")
    follow_ids = user.follows_by_type("Individual").map{|i| i.followable_id}
    #upvoted_ids = user.upvotes.pluck(:agreement_id)
    upvoted_ids = (follow_ids + [user.id]).map do |user_or_sb_she_follows_id|
      Individual.find(user_or_sb_she_follows_id).upvotes.pluck(:agreement_id)
    end.flatten
    # TODO: Add to the view who of your users upvoted
    users_agreements = Agreement.where(individual_id: user.id)
    users_upvoted = Agreement.where(id: upvoted_ids)
    @agreements = Agreement.where(id: follow_ids).or(users_agreements).or(users_upvoted).where("reason is not null and reason != ''").order(created_at: :desc).page(params[:page] || 1).per(10)
  end
end
