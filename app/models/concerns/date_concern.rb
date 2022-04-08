module DateConcern
  extend ActiveSupport::Concern

  included do
    # def format_date(date)
    #   date&.to_date
    # rescue StandardError
    #   raise 'Invalid Date provided to Media.format_date'
    # end

    def self.format_date(date)
      return unless date

      date.to_date
    rescue StandardError
      raise 'Invalid Date provided to Media.format_date'
    end

    # @param from: Date object, or "2022-04-26" string. Defaults to all
    # @param to: Date object, or "2022-05-26" string. Defaults to today's date
    def self.by_dates(from: nil, to: nil)
      from = format_date(from) || 0
      to = format_date(to) || DateTime.now.utc.to_date
      all_with_cache&.select do |item|
        item_date = format_date(item[:external_created_at])
        item_date.between?(from, to)
      end
    end

    def self.all_grouped_by_date
      all_with_cache&.group_by { |item| item[:external_created_at].to_date }
    end
  end

end