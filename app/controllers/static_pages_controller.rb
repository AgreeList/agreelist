class StaticPagesController < ApplicationController
  def join
    @individual = current_user
  end

  def home
    if Rails.env == "test"
      @statements, @individuals = [], []
      9.times do
        @statements << Statement.first
        @individuals << Individual.first
      end
    else
      @statements = urls.map{ |s| Statement.find_by_hashed_id(s.split("-").last) }
      @individuals = twitters.map{ |t| Individual.find_by_twitter(t) }
    end
    @statement = Statement.new if current_user
  end

  def contact
  end

  private

  def urls
    %w(http://www.agreelist.com/s/launch-early-get-feedback-and-start-iterating-kibothy610sj
       http://www.agreelist.com/s/entrepreneurs-should-have-a-sense-of-purpose-0u5gaxuav1w8
       http://www.agreelist.com/s/seek-out-negative-feedback-5brqzh7xaj5b
       http://www.agreelist.com/s/a-single-founder-in-a-startup-is-a-mistake-5udqtimqiicb
       http://www.agreelist.com/s/location-is-important-for-a-startup-zfrtumvrwtyd
       http://www.agreelist.com/s/stay-self-funded-as-long-as-possible-73rbrkrvztwb
       http://www.agreelist.com/s/don-t-go-all-in-with-your-business-re3xkpjeunfp
       http://www.agreelist.com/s/go-with-your-gut-rx54xxorby6y
       http://www.agreelist.com/s/don-t-give-up-olyhqve6j6sf
       http://www.agreelist.com/s/set-goals-4m7m7oidosa8)
  end

  def twitters
    %w(reidhoffman edyson elonmusk paulg petercohan gmc tferriss richardbranson dilbert_daily)
  end
end
