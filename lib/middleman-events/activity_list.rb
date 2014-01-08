require 'time'

module Middleman
  module Events

  	class ActivityList

      def initialize(activities, venue)
        @activities = activities.map{|activity| Activity.new(activity, venue)}

        @filtered_activities = Array.new
      end

      def filter
        @filtered_activities = @activities
        self
      end

      def filtered_length
        @filtered_activities.length
      end

      def upcoming
        @filtered_activities = @filtered_activities.reject{|activity| activity.date_time < Time.now}
        self
      end

      def past
        @filtered_activities = @filtered_activities.reject{|activity| activity.date_time > Time.now}
        self
      end

      def public
        @filtered_activities = @filtered_activities.reject{|activity| activity.public != true}
        self
      end

      def ascending
        @filtered_activities = @filtered_activities.sort_by{|activity| activity.date_time}
        self
      end

      def descending
        @filtered_activities = @filtered_activities.sort_by{|activity| activity.date_time}.reverse
        self
      end

      def filtered
        @filtered_activities
      end

      def activities
        @activities
      end
    end

  end
end