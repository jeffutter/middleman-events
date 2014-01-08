require "middleman-core"

require "middleman-events/version"

::Middleman::Extensions.register(:events) do
  require "middleman-events/fancy_hash"
  require "middleman-events/activity"
  require "middleman-events/activity_list"
  require "middleman-events/event"
  require "middleman-events/event_list"
  require "middleman-events/venue"
  require "middleman-events/group"

  require "middleman-events/ical"
  require "middleman-events/extension"
  ::Middleman::Events
end