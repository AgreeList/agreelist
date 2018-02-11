module StatementsHelper
  def shorten_if_too_long(string)
    max = 85
    string.size > max ? "#{string[0..(max - 1)]}..." : string
  end

  def any_filter?
    params[:type] == "nobel laureates" || params[:type] == "people" || params[:type] == "influencers" || params[:occupation].present? || params[:school].present? || params[:v] == "agree" || params[:v] == "disagree"
  end
end
