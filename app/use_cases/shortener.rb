class Shortener
  attr_reader :full_url, :object

  def initialize(args)
    @full_url = args[:full_url]
    @object = args[:object]
  end

  def get
    if cached_shortened_url
      cached_shortened_url
    else
      # TODO: Replace shortener gem. It stopped working and it doesn't seem that it will be fixed.
      # $redis.set(key, shorten_url)
      # shorten_url
      full_url
    end
  end

  def clean_cache
    $redis.del(key)
  end

  private

  def cached_shortened_url
    @cached_shortened_url ||= $redis.get(key)
  end

  def shorten_url
    @shorten_url ||= Google::UrlShortener.shorten!(full_url)
  end

  def key
    @key ||= "shortener:#{class_name}:#{id}"
  end

  def class_name
    object.class.to_s.downcase
  end

  def id
    object.id
  end
end
