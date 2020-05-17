class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :signed_in?, :admin?, :can_delete_statements?, :has_admin_category_rights?, :main_statement, :has_profession_rights?, :has_update_individual_rights?, :board?, :back_url, :google_analytics_events
  before_action :set_page_type
  before_action :redirect_www
  before_action :set_anoymous_id, if: -> { current_user.nil? && anonymous_id.nil? }

  attr_reader :google_analytics_events

  private

  def set_anoymous_id
    session[:anonymous_id] = SecureRandom.urlsafe_base64
    Analytics.identify(
      anonymous_id: anonymous_id
    )
  end

  def anonymous_id
    session[:anonymous_id]
  end

  def redirect_www
    if request.host == 'www.agreelist.org'
      redirect_to 'https://agreelist.org' + request.fullpath, status: 301
    end
  end

  def notify(event, args = {})
    session[:ga_events] = [] if session[:ga_events].nil?
    session[:ga_events] << event # we use the session in case we redirect
    arguments = { event: event, current_user_id: current_user.try(:id), ip: request.try(:remote_ip) }.merge(args)
    EventNotifier.new(arguments).notify
  end

  def current_user
    user_from_session
  end

  def user_from_session
    @user_from_session ||= Individual.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    current_user.present?
  end

  def admin?
    current_user.try(:admin)
  end

  def can_delete_statements?
    current_user.try(:twitter).try(:downcase) == "arpahector"
  end

  def has_admin_category_rights?
    %w(emilie_esposito arpahector ryryanryanry).include?(current_user.try(:twitter).try(:downcase))
  end

  def has_profession_rights?
    has_admin_category_rights?
  end

  def has_update_individual_rights? # required for professions because it calls individuals controller #update
    has_admin_category_rights?
  end

  def login_required
    unless signed_in?
      session[:back_url] = request.url
      flash[:notice] = "Login required for this page"
      redirect_to login_path
    end
  end

  def admin_required
    redirect_to "/", notice: "admin required" unless admin?
  end

  def category_admin_required
    redirect_to "/", notice: "admin required" unless has_admin_category_rights?
  end

  def profession_rights_required
    redirect_to "/", notice: "admin required" unless has_profession_rights?
  end

  def main_statement
    Rails.env.test? ? Statement.first : Statement.find(7)
  end

  def board?
    @statement == main_statement
  end

  def back_url_with_no_parameters
    request.referer.gsub(/\?.*/,'')
  end

  def back_url
    session[:back_url]
  end

  def get_and_delete_back_url
    url = back_url
    if url
      session[:back_url] = nil
      url
    end
  end

  def set_back_url_to_current_page
    session[:back_url] = request.url
  end

  def load_occupations_and_schools(args)
    @occupations_count = OccupationsCache.new(statement: args[:statement], min_count: args[:min_count] || 1).read.first(args[:number])
    @schools_count = SchoolsCache.new(statement: args[:statement], min_count: args[:min_count] || 1).read.first(args[:number])
  end

  def set_page_type
    @page_type = "#{params[:controller]}-#{params[:action]}"
  end

  def google_analytics_events
    # We delete it because we only want to send it once to google analytics
    # We use the session for those actions which redirect users
    session.delete(:ga_events).try(:uniq) || []
  end

  def add_meta_tags(args)
    meta_tags = {
      title: args[:title],
      description: args[:description],
      fb: { app_id: ENV["FB_APP_ID"] },
      og: {
        title: args[:title],
        description: args[:description],
        url: request.url,
        type: "website"
      },
      twitter: {
        site: "@agreelist",
        card: "summary",
        title: args[:title],
        description: args[:description],
        domain: request.base_url
      }
    }
    if args[:picture_object].try(:picture?)
      meta_tags[:og] = meta_tags[:og].merge(image: args[:picture_object].picture(:square))
      meta_tags[:twitter] = meta_tags[:twitter].merge(image: {src: args[:picture_object].picture(:square)})
    end
    set_meta_tags meta_tags
  end
end
