class Agreement::Filter
  attr_reder :args
  def initialize(args)
    @args = args
  end

  def filter!
    filter = {}
    filter.each do |key, value|
      filter[key] = args[key] if args[key].present?
    end

    filter[:type] = nil if filter[:type] == "influencers"
    filter[:school] = nil if filter[:school] == "any"
    filter[:occupation] = nil if filter[:occupation] == "any"


    @agreements = Agreement
    if filter[:occupation].present?
      if filter[:school].present?
        @agreements = @agreements.two_contexts("occupations", filter[:occupation], "schools", filter[:school])
      else
        @agreements = @agreements.context("occupations", filter[:occupation])
      end
    elsif filter[:school].present?
      @agreements = @agreements.context("schools", filter[:school])
    end

    @agreements = @agreements.joins("left join individuals on individuals.id=agreements.individual_id")
    if filter[:type].nil?
      @agreements = @agreements.where("individuals.wikipedia is not null and individuals.wikipedia != ''")
    elsif filter[:type] == "people"
      @agreements = @agreements.where("individuals.wikipedia is null or individuals.wikipedia = ''")
    end
  end
end
