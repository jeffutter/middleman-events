require 'time'

module Middleman
  module Events

  	class EventList

      def initialize(events, venues, groups)

        @venues = venues.sort.each_with_object({}) do |(name, venue), h|
          h[name] = Venue.new(venue, name, self)
        end

        @groups = groups.sort.each_with_object({}) do |(name, group), h|
          h[name] = Group.new(group, name, self)
        end

        @events = events.each_with_object({}) do |(id, event), h|
          venue = @venues[event['venue']]
          group = @groups[event['group']]
          h[id] = Event.new(event, id, venue, group)
        end

        @filtered_events = Array.new
      end

      def filter
        @filtered_events = @events
        self
      end

      def filtered
        @filtered_events
      end

      def filtered_length
        @filtered_events.length
      end

      def by_month_year
        @filtered_events.values.group_by{|e| e.date_time.strftime('%B %Y')}
      end

      def group_by_year_month_day
        @filtered_events.values.each_with_object({}) do |event, h|
          h[event.year] ||= Hash.new
          h[event.year][event.month] ||= Hash.new
          h[event.year][event.month][event.day] ||= Array.new
          h[event.year][event.month][event.day] << event
        end
      end

      def upcoming
        @filtered_events = @filtered_events.each_with_object({}) do |(key, event), h|
          if event.date_time_utc > Time.now.utc
            h[key] = event
          end
        end
        self
      end

      def past
        @filtered_events = @filtered_events.each_with_object({}) do |(key, event), h|
          if event.date_time_utc < Time.now.utc
            h[key] = event
          end
        end
        self
      end

      def published
        @filtered_events = @filtered_events.each_with_object({}) do |(key, event), h|
          if event.published == true
            h[key] = event
          end
        end
        self
      end

      def latest(number)
        @filtered_events = Hash[@filtered_events.to_a[0..(number-1)]]
        self
      end

      def range(range)
        @filtered_events = Hash[@filtered_events.to_a[range]]
        self
      end

      def chunk(indexes)
        @filtered_events = Hash[@filtered_events.to_a.values_at(*indexes)]
        self
      end

      def ascending
        @filtered_events = Hash[@filtered_events.sort_by{|key, event| event.date_time}]
        self
      end

      def descending
        @filtered_events = Hash[@filtered_events.sort_by{|key, event| event.date_time}.reverse]
        self
      end

      def in_group(group_name)
        @filtered_events.reject!{|key,event| event.group.name != group_name }
        self
      end

      def in_venue(venue_name)
        @filtered_events.reject!{|key,event| event.venue.name != venue_name }
        self
      end

      def in_range(start_time, end_time)
        @filtered_events.reject!{|key,event| ! (start_time..end_time).cover?(event.date_time) }
        self
      end

      def years_months_days
        hash = @filtered_events.values.each_with_object({}) do |event, h|
          h[event.year] ||= Hash.new
          h[event.year][event.month] ||= Array.new
          h[event.year][event.month] << event.day
          h[event.year][event.month].uniq!
        end
        hash
      end

      def events
        @events
      end

      def venues
        @venues
      end

      def groups
        @groups
      end
    end

  end
end