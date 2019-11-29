class EventWorker
  include Sidekiq::Worker

  def perform(args)
    event = args["event"]
    arguments = args.map{|k,v| "#{k}: #{v}"}.join(", ")
    if args["current_user_id"].present?
      c = Individual.find(args["current_user_id"])
      user_data = "#{c.name} (@#{c.twitter}, #{c.email})"
    else
      user_data = ""
    end
    LogMailer.log_email("#{event}, #{user_data}, #{arguments}").deliver
  end
end
