require 'active_support/core_ext'

module Middleman
  module Events
    class << self

      attr_accessor :options

      def registered(app, options={})

        options[:basedir]                 ||= 'events'
        options[:time_zone]               ||= 'America/Chicago'
        options[:pagination_length]       ||= 15
        options[:name]                    ||= 'Icalendar'
        options[:group_template]          ||= 'events/group_template.html'
        options[:venue_template]          ||= 'events/venue_template.html'
        options[:event_template]          ||= 'events/event_template.html'
        options[:event_index_template]    ||= 'events/event_index_template.html'
        Events.options = options

        app.helpers Helpers

        app.after_configuration do

          #stash the source images dir in options for the Rack middleware

          after_build do |builder|
          end

          sitemap.register_resource_list_manipulator(:events, SitemapExtension.new(self), true)
        end
      end
      alias :included :registered
    end

    module Helpers
      def short_event_list
        event_list = EventList.new(data.events, data.venues, data.groups)
        groups = event_list.groups
        venues = event_list.venues
        @events = event_list.filter.published.upcoming.ascending.latest(3).filtered

        html = "<dl>"
        @events.each do |key, event|
          html << "<dt><a href='#{event.url}'>#{event.group.name}: #{event.title} - #{event.venue.city}, #{event.venue.state}</a></dt>"
          html << "<dd><a href='#{event.url}'>#{event.date_time.strftime('%b %d - %I:%M %P')}</a></dd>"
        end
        html << "</dl>"
        
        html
      end
    end

    class SitemapExtension
      def initialize(app)
        @app = app
        @app.ignore(Events.options[:venue_template]) if Events.options[:venue_template]
        @app.ignore(Events.options[:group_template]) if Events.options[:group_template]
        @app.ignore(Events.options[:event_template]) if Events.options[:event_template]
        @app.ignore(Events.options[:event_index_template]) if Events.options[:event_index_template]
      end

      def manipulate_resource_list(resources)
        event_list = EventList.new(@app.data.events, @app.data.venues, @app.data.groups)

        ics_resource = ICSResource.new(@app.sitemap, ::Middleman::Util.normalize_path(Events.options[:basedir]+'/events.ics'), event_list.events)

        group_resources = []
        venue_resources = []
        event_resources = []
        event_index_resources = []

        event_list.groups.each do |name, group|
          group_resources << Sitemap::Resource.new(@app.sitemap, group.path).tap do |p|
            p.proxy_to(Events.options[:group_template])
            p.add_metadata locals: { :group => group }
          end
        end

        event_list.venues.each do |name, venue|
          venue_resources << Sitemap::Resource.new(@app.sitemap, venue.path).tap do |p|
            p.proxy_to(Events.options[:venue_template])
            p.add_metadata locals: { :venue => venue }
          end
        end

        event_list.filter.published.filtered.each do |id, event|
          event_resources << Sitemap::Resource.new(@app.sitemap, event.path).tap do |p|
            p.proxy_to(Events.options[:event_template])
            p.add_metadata locals: { :event => event }
          end
        end

        event_list.filter.published.ascending.years_months_days.each do |year, months|

          event_index_resources.concat paginate_event_index(
            Events.options[:basedir]+"/#{year}/",
            "#{year}",
            event_list.filter.published.in_range(Time.new(year), Time.new(year)+1.year).descending
          )

          months.each do |month, days|

            event_index_resources.concat paginate_event_index(
              Events.options[:basedir]+"/#{year}/#{month}/",
              "#{year}-#{month}",
              event_list.filter.published.in_range(Time.new(year, month), Time.new(year, month)+1.month).descending
            )

            days.each do |day|
              
              event_index_resources.concat paginate_event_index(
                Events.options[:basedir]+"/#{year}/#{month}/#{day}/",
                "#{year}-#{month}-#{day}",
                event_list.filter.published.in_range(Time.new(year, month, day), Time.new(year, month, day)+1.day).descending
              )

            end
          end
        end

        event_index_resources.concat paginate_event_index(
          Events.options[:basedir],
          "Come and listen",
          event_list.filter.published.descending
        )

        resources + [ics_resource] + group_resources + venue_resources + event_resources + event_index_resources
      end

      def paginate_event_index(path, subtitle, events)
        page_ranges = (0..events.filtered_length-1).each_slice(Events.options[:pagination_length]).to_a

        ranges = page_ranges.each_with_object({}) do |range, h|
          index = page_ranges.index(range) + 1
          h[range] ||= {}
          h[range][:name] =  index > 1 ? "page#{index.to_s.rjust(2,'0')}" : ''
          h[range][:path] = File.join("/",path, h[range][:name], 'index.html')
          h[range][:index] = index
        end

        resources = []

        ranges.each do |range, page|
          event_chunk = events.dup.chunk(range)

          resources << event_index_resource(page[:path], subtitle, event_chunk, page, ranges.values)
        end

        resources
      end

      def event_index_resource(path, subtitle, events, current_page, pages)
        Sitemap::Resource.new(@app.sitemap, ::Middleman::Util.normalize_path(path)).tap do |p|
          p.proxy_to(Events.options[:event_index_template])
          p.add_metadata locals: {
            :subtitle => subtitle,
            :upcoming_events => events.dup.upcoming.ascending,
            :past_events => events.dup.past,
            :cur_page => current_page,
            :previous_page => pages[pages.index(current_page)-1],
            :next_page => pages[pages.index(current_page)+1],
            :pages => pages
          }
        end
      end

    end

    class ICSResource < Middleman::Sitemap::Resource
      def initialize(store, path, events)
        @events = events
        super(store, path)
      end
      def render(opts={}, locs={}, &block)
        ical = Ical.new(events: @events.values, title: Events.options[:name])
        ical.to_ical
      end
      def source_file
        ""
      end
      def binary?
        false
      end
    end

  end
end