require 'icalendar'
require 'date'

module Middleman
  module Events

    class Ical
      attr_accessor :ical

      def initialize(events: Array.new, title: nil)
        @ical = Icalendar::Calendar.new
        @ical.prodid = "Artist Events"
        @ical.custom_property("X-WR-CALNAME;VALUE=TEXT", "#{title} - Events")
        add_events(events) if events and events.length > 0
      end

      def add_events(events)
        events.each do |event|
          add_event(event)
        end
      end

      def add_event(event)
        add_activities(event.activities.activities, event)
      end

      def add_activities(activities, event)
        activities.each do |activity|
          add_activity(activity, event)
        end
      end

      def add_activity(activity, event)
        timestr = "%Y%m%dT%H%M%SZ"

        location = Array.new
        location << event.venue.address1 if event.venue.has_prop?(:address1)
        location << event.venue.address2 if event.venue.has_prop?(:address2)
        location << event.venue.city if event.venue.has_prop?(:city)
        location << event.venue.state+','+event.venue.zip

        @ical.event do
          dtstart     activity.start_in_utc.strftime(timestr)
          dtend       activity.end_in_utc.strftime(timestr)
          dtstamp     activity.created_at_in_utc.strftime(timestr)
          summary     "#{event.group.name} - #{event.title}: #{activity.name}"
          description event.details if event.methods.include?(:details)
          status      'CONFIRMED'
          ip_class    'PUBLIC' # or it doesn't show the title or any details in google calendar
          location    location.join(' ')
          if event.venue.has_prop?(:website)
            url event.venue.website
          end
        end
      end

      def to_ical
        @ical.publish
        return @ical.to_ical
      end

    end
  end
end