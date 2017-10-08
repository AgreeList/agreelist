module ApplicationHelper
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

  def donate_path(statement)
    contact_path(statement: statement.hashed_id, subject: "Help me to find influencers", body: "Hi,\n\nI'd like to donate $100 so you can help me to find 50 influencers for the topic or statement: #{statement.content}\n\nCheers")
  end
end
