# Based on the SuperMemo 2 algorithm as described here:
# http://www.supermemo.com/english/ol/sm2.htm
require 'date'

module SRS
	module Schedulers
		class SuperMemo2
			DEFAULT_EF = 2.5
			MIN_EF = 1.3
			FIRST_INTERVAL = 1
			SECOND_INTERVAL = 6
			ITERATION_RESET_BOUNDARY = 3.0 / 5.0
			REPEAT_BOUNDARY = 4.0 / 5.0

			def initialize()
			end

			def first_rep(score)
				fields = {
					"Due"           => (Date.today + FIRST_INTERVAL).to_time,
					"Repeat"        => score < REPEAT_BOUNDARY ? true : false,
					"E-Factor"      => adjust_efactor(DEFAULT_EF, score),
					"Interval"      => FIRST_INTERVAL,
					"Iteration"     => 1
				}

				return fields
			end

			def rep(score, fields)
				ef = fields["E-Factor"].to_f
				interval = fields["Interval"].to_i
				iteration = fields["Iteration"].to_i
				repeat = (fields["Repeat"] == "true")

				if not repeat then
					iteration = 0 if score < ITERATION_RESET_BOUNDARY
					case iteration
					when 0
						interval = FIRST_INTERVAL
					when 1
						interval = SECOND_INTERVAL
					else
						interval = adjust_interval(interval, ef)
					end

					ef = adjust_efactor(ef, score)
				end

				fields["Due"] = (Date.today + interval).to_time
				fields["Repeat"] = score < REPEAT_BOUNDARY ? true : false
				fields["E-Factor"] = ef
				fields["Interval"] = interval
				fields["Iteration"] = iteration + 1

				return fields
			end

			def adjust_efactor(ef, score)
				q = score * 5
				adjusted_efactor = ef + (0.1-(5.0 - q) * (0.08 + (5.0 - q) * 0.02))

				adjusted_efactor < MIN_EF ? MIN_EF : adjusted_efactor
			end

			def adjust_interval(interval, ef)
				(interval * ef).round
			end
		end
	end
end

