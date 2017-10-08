class EventWorker
  include Sidekiq::Worker

  def perform(args)
    event = args["event"]
    c = Individual.find(args["current_user_id"])
    arguments = args.map{|k,v| "#{k}: #{v}"}.join(", ")
    LogMailer.log_email("#{event}, #{c.name} (@#{c.twitter}, #{c.email}), #{arguments}").deliver
  end
end
