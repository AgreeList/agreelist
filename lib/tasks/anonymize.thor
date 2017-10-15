class Anonymize < Thor
  desc "db",
       "delete sensitive data from database"
  def db
    require './config/environment'
    if Rails.env.development?
      puts Individual.update_all(email: nil, password_digest: nil, activation_digest: nil, reset_digest: nil)
      puts BetaEmail.destroy_all
    end
  end
end
