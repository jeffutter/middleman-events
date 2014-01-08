module Middleman
  module Events

    class Event < FancyHash

      def initialize(event, id, venue, group)
        @event = event
        @venue = venue
        @group = group

        @activities = ActivityList.new(event['activities'], venue)
        @id = id
      end

      def venue
        @venue
      end

      def group
        @group
      end

      def activities
        @activities
      end

      def date_time
        public_activities.min{ |a, b| a.date_time <=> b.date_time }.date_time
      end

      def date_time_utc
        public_activities.min{ |a, b| a.start_in_utc <=> b.start_in_utc }.start_in_utc
      end

      def public_activities
        @activities.filter.public.filtered
      end

      def month
        date_time.month
      end

      def year
        date_time.year
      end

      def day
        date_time.day
      end

      def slug
        self.title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
      end

      def path
        ::Middleman::Util.normalize_path(Events.options[:basedir]+"/#{year}/#{month}/#{day}/#{slug}/index.html")
      end

      def url
        ::Middleman::Util.normalize_path(Events.options[:basedir]+"/#{year}/#{month}/#{day}/#{slug}/")
      end

      def id
        @id
      end

    end

  end
end