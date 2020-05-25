module ApplicationHelper
  def mobile?
    request.user_agent =~ /Mobile/
  end

  def links_to_tags(individual)
    raw individual.tags.map(&:name).map{ |t| link_to(t, tag_path(t))}.join(", ")
  end

  def tag_path(t)
    "/tags/#{t}"
  end

  def percentage_of_supporters(statement)
    statement.number_of_supporters * 100 / statement.number_of_opinions
  end

  def shortened_url_without_params(statement)
    Rails.env.test? ? request.url : Shortener.new(full_url: request.base_url + request.path, object: statement).get
  end

  def donate_path
    "https://opencollective.com/agreelist"
  end
end
