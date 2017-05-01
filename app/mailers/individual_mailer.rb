class IndividualMailer < ActionMailer::Base
  def password_reset(individual)
    @individual = individual
    @base_url = Rails.env.production? ? "http://www.agreelist.org" : "http://www.localhost:3000"
    mail(to: individual.email, from: "hello@agreelist.org", subject: "AgreeList - Password Reset")
  end

  def account_activation(individual)
    @individual = individual
    @base_url = Rails.env.production? ? "http://www.agreelist.org" : "http://www.localhost:3000"
    mail(to: individual.email, from: "hello@agreelist.org", subject: "AgreeList - Account activation")
  end
end
