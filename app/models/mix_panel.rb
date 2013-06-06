class MixPanel
  class << self
    def track(event, properties={}, user_info=nil, env={})
      tracker = Mixpanel::Tracker.new("981a7a6da84c67bb7faeec8db0143beb", { :env => env })
      tracker.set(user_info.user_id, user_info.to_hash)
      tracker.track(event, properties.merge(:distinct_id => user_info.user_id))
    end
    handle_asynchronously :track, :queue => 'mixpanel'
  end
end
