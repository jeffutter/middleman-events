require 'time'
require 'tzinfo'

module Middleman
  module Events

    class Activity < FancyHash

      def initialize(activity, venue)
        @activity = activity
        @venue = venue

        @activity['created_time_zone'] ||= Events.options[:time_zone]
        @activity['time_zone'] ||= Events.options[:time_zone]
      end

      def time_zone
        @venue.time_zone
      end

      def tzinfo
        TZInfo::Timezone.get(@activity['time_zone'])
      end

      def created_at_tzinfo
        TZInfo::Timezone.get(@activity['created_time_zone'])
      end
      
      def date_time
        tzinfo.utc_to_local(start_in_utc)
      end

      def start_in_utc
        tzinfo.local_to_utc(Time.parse(@activity['date_time']))
      end

      def created_at_in_utc
        created_at_tzinfo.local_to_utc(Time.parse(@activity['created_date_time']))
      end

      def end_in_utc
        (start_in_utc+(@activity['duration']*60)).utc
      end

    end

  end
end