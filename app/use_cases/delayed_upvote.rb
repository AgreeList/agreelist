module DelayedUpvote
  private

  def upvote(args = {})
    agreement = Agreement.find(params[:agreement_id])
    if Upvote.exists?(individual: current_user, agreement: agreement)
      redirect_to(args[:redirect_to] || root_path, notice: "Already was upvoted!")
    else
      Upvote.create(individual: current_user, agreement: agreement)
      notify("upvote")
      agreement.update_attribute(:upvotes_count, agreement.upvotes.count)
      redirect_to(args[:redirect_to] || root_path, notice: "Upvoted!")
    end
  end
end
