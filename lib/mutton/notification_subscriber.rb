module Mutton
  class NotificationSubscriber

    if Mutton.subscribe_notifications?
      ActiveSupport::Notifications.subscribe 'render_template.Mutton' do |_name, started, finished, _unique_id, data|
        total_time = ((finished - started) * 1000).round(0)
        Mutton.logger.debug "  Mutton::Handler::Render Total Time #{total_time} ms [ Content Retrieval: #{data[:content_retrieval_time]} ms Compile: #{data[:compile_time]} ms ]" if Mutton.logger
        # puts data.inspect # {:this=>:data}
      end

      ActiveSupport::Notifications.subscribe 'evaluate_asset.Mutton' do |_name, started, finished, _unique_id, data|
        total_time = ((finished - started) * 1000).round(0)
        Mutton.logger.info "   Mutton::Evaluation(Asset Pipeline) Total Time #{total_time} ms [ Source Lookup: #{data[:source_time]} ms Pre-Compile: #{data[:precompile_time]} ms ]" if Mutton.logger
        # puts data.inspect # {:this=>:data}
      end
    end
  end
end
