include FactoryBot::Syntax::Methods
include ActionDispatch::TestProcess

tracker = Tracker.last

def create_event(*args)
  event_record = build(*args)
  tracker = event_record.tracker
  unless tracker.persisted?
    tracker.save!
    event_record.tracker_id = tracker.id
  end
  now = Time.current
  event_record.created_at = now
  event_record.updated_at = now
  Db::Events::Facade.insert(tracker: tracker, events: [event_record.attributes])
  events = Db::Events::Facade.fetch(tracker.id)
  events.sort_by(&:created_at).last
end

event_1 = create_event(:tracking_event, tracker_id: tracker.id, status: Enum::TrackingStatuses::OUT_FOR_DELIVERY, happened_at: Time.current - 1.second)
event_2 = create_event(:tracking_event, tracker_id: tracker.id, status: Enum::TrackingStatuses::DELAYED, happened_at: Time.current)
