class StaticPagesController < ApplicationController
  before_action :set_back_url_to_current_page, only: [:about]
  before_action :statements_to_vote, only: :advice_for_entrepreneurs

  def donors
  end

  def contact
    if current_user && params[:body] =~ /donate/
      statement = Statement.find_by_hashed_id(params['statement'])
      notify("clicked_on_donate_100_for_topic", statement_content: statement.try(:content))
    end
  end

  def contact_send_email
    notify("contact_form", name: params[:name], email: params[:email], body: params[:body])
    ContactMailer.contact(current_user, params).deliver
    flash[:notice] = "Done. We'll reply soon. If not, you can email us directly to hello@agreelist.org or via Twitter at @arpahector"
    redirect_to get_and_delete_back_url || root_path
  end

  def join
    @individual = current_user
  end

  def email
    LogMailer.log_email("email: #{params[:email]}, comment: #{params[:comment]}").deliver
    email = BetaEmail.new(email: params[:email], comment: params[:comment])
    if email.save
      redirect_to "/", notice: "Email saved"
    else
      redirect_to "/", notice: "There was an error. Please try again"
    end
  end

  def polar
  end

  def about
    redirect_to "https://opencollective.com/agreelist"
  end

  def create_statement_from_homepage
  end

  def advice_for_entrepreneurs
    if Rails.env == "test"
      test_home
    else
      @statements = urls.map{ |s| Statement.find_by_hashed_id(s.split("-").last) }
      @individuals = twitters.map{ |t| Individual.find_by_twitter(t) }
    end
    @contents = contents
  end
  private

  def statements_to_vote
    if current_user
      @statements_to_vote = (Statement.tagged_with("entrepreneurship") - current_user.statements).sort_by{|s| s[:created_at]}.map{|s| [s.id, s.content, statement_path(s), s.agree_counter, s.disagree_counter]}
    else
      @statements_to_vote = []
    end
  end

  def test_home
    @statements, @individuals = [], []
    9.times do
      @statements << Statement.first
      @individuals << Individual.first
    end
  end

  def urls
    %w(http://www.agreelist.org/s/launch-early-get-feedback-and-start-iterating-kibothy610sj
       http://www.agreelist.org/s/entrepreneurs-should-have-a-sense-of-purpose-0u5gaxuav1w8
       http://www.agreelist.org/s/seek-out-negative-feedback-5brqzh7xaj5b
       http://www.agreelist.org/s/a-single-founder-in-a-startup-is-a-mistake-5udqtimqiicb
       http://www.agreelist.org/s/consider-crowdfunding-to-fund-your-startup-1cp4tkljelvw
       http://www.agreelist.org/s/stay-self-funded-as-long-as-possible-73rbrkrvztwb
       http://www.agreelist.org/s/don-t-go-all-in-with-your-business-re3xkpjeunfp
       http://www.agreelist.org/s/go-with-your-gut-rx54xxorby6y
       http://www.agreelist.org/s/don-t-give-up-olyhqve6j6sf
       http://www.agreelist.org/s/set-goals-4m7m7oidosa8)
  end

  def contents
    ["Launch early, get feedback and start iterating",
     "Entrepreneurs should have a sense of purpose",
     "Seek out negative feedback",
     "A single founder in a startup is a mistake",
     "Consider crowdfunding to fund your startup",
     "Stay self-funded for as long as possible",
     "Don’t go all in with your business",
     "Listen to others but go with your gut",
     "Don’t give up"
    ]
  end

  def twitters
    %w(reidhoffman edyson elonmusk paulg guykawasaki gmc tferriss richardbranson dilbert_daily)
  end
end
