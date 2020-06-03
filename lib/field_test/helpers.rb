module FieldTest
  module Helpers
    def field_test(experiment, **options)
      exp = FieldTest::Experiment.find(experiment)

      participants = FieldTest::Participant.standardize(options[:participant] || field_test_participant)

      if try(:request)
        options = options.dup

        params_variant =
          if !options[:variant] && params[:field_test] && params[:field_test][experiment] && exp.variants.include?(params[:field_test][experiment])
            params[:field_test][experiment]
          end

        if FieldTest.exclude_bots?
          options[:exclude] = Browser.new(request.user_agent).bot?
        end

        options[:exclude] ||= FieldTest.excluded_ips.any? { |ip| ip.include?(request.remote_ip) }

        options[:ip] = request.remote_ip
        options[:user_agent] = request.user_agent
        # cache results for request
        @field_test_cache ||= {}

        # don't update variant when passed via params
        @field_test_cache[experiment] ||= params_variant || exp.variant(participants, options)
      else
        exp.variant(participants, options)
      end
    end

    def field_test_converted(experiment, **options)
      exp = FieldTest::Experiment.find(experiment)

      participants = FieldTest::Participant.standardize(options[:participant] || field_test_participant)

      exp.convert(participants, goal: options[:goal])
    end

    # TODO fetch in single query
    def field_test_experiments(**options)
      participants = FieldTest::Participant.standardize(options[:participant] || field_test_participant)
      experiments = {}
      participants.each do |participant|
        FieldTest::Membership.where(participant.where_values).each do |membership|
          experiments[membership.experiment] ||= membership.variant
        end
      end
      experiments
    end
  end
end
