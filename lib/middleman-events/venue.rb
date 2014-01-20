module Middleman
  module Events

    class Venue < FancyHash

      def initialize(venue, name, event_list)
        @venue = venue
        @name = name
        @event_list = event_list
        @venue['time_zone'] ||= Events.options[:time_zone]
      end

      def name
        @name
      end

      def upcoming_events
        @event_list.filter.published.in_venue(name).upcoming.ascending
      end

      def past_events 
        @event_list.filter.published.in_venue(name).past.descending
      end

      def upcoming_events_by_month_year
        upcoming_events.values.group_by{|e| e.date_time.strftime('%B %Y')}
      end

      def past_events_by_month_year
        past_events.values.group_by{|e| e.date_time.strftime('%B %Y')}
      end

      def path
        ::Middleman::Util.normalize_path(Events.options[:basedir]+"/venues/#{slug}/index.html")
      end

      def url
        File.join('/',Events.options[:basedir],"/venues/#{slug}/")
      end

    end

  end
end