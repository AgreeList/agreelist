class HomeController < ApplicationController
  def index
    s = ["AI and robots might cause mass unemployment", "AI will pose a serious risk to society within the next 50 years", "Social media threaten democracy", "Basic Income", "Carbon Tax"]
    @statements = Statement.where(content: s).order("LENGTH(content) DESC")
  end
end
