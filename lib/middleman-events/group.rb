module Middleman
  module Events

    class Group < FancyHash

      def initialize(group, name, event_list)
        @group = group
        @name = name
        @event_list = event_list
      end

      def name
        @name
      end

      def event_list
        @event_list
      end

      def upcoming_events
        @event_list.filter.published.in_group(name).upcoming.ascending
      end

      def past_events
        @event_list.filter.published.in_group(name).past.descending
      end

      def path
        ::Middleman::Util.normalize_path(Events.options[:basedir]+"/groups/#{slug}/index.html")
      end

      def url
        File.join('/',Events.options[:basedir]+"/groups/#{slug}/")
      end

    end

  end
end