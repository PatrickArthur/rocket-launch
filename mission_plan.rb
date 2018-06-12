require 'probability'

# Helper Module for Mission Plan class
module MissionPlanHelper
  def print_mission_status(burn_rate, current_speed, time_to_dest)
    puts "  Current fuel burn rate: #{burn_rate} liters/min"
    puts "  Current speed: #{current_speed} km/h"
    puts "  Current distance traveled: #{@current_distance} km"
    puts "  Elapsed time: #{@t.strftime('%-H:%M:%S')}"
    puts "  Time to destination: #{time_to_dest.strftime('%-H:%M:%S')}"
  end
end

# Handles the Mission Plan
class MissionPlan
  attr_reader :distance, :payload, :capacity, :burn_rate, :avg_speed, \
              :plan, :random_seed
  include MissionPlanHelper

  def initialize(distance, payload, capacity, burn_rate, avg_speed)
    @distance = distance.to_f
    @payload = format_with_commas(payload)
    @capacity = format_with_commas(capacity)
    @burn_rate = format_with_commas(burn_rate)
    @avg_speed = format_with_commas(avg_speed)
    @total_distance = 0
    @total_fuel_burned = 0
    @total_flight_time = Time.new(0)
  end

  def mission_details
    mission_plan_data.each { |key, val| puts '  ' + key + val }
  end

  def mission_status(aborts, retries, explosions, will_explode)
    iteration_to_explode = retrieve_iteration_to_explode(will_explode)
    @t = Time.new(0)
    @current_distance = 0
    (0..11).each do |i|
      return handle_explosion if iteration_to_explode == i
      handle_mission_status
    end
    finish_mission_status(aborts, [retries, explosions])
  end

  def mission_summary(aborts, retries, explosions)
    puts 'Mission summary:'
    puts "  Total distance traveled: #{format_with_commas(@total_distance)} km"
    puts "  Number of abort and retries: #{aborts}/#{retries}"
    puts "  Number of explosions: #{explosions}"
    puts "  Total fuel burned: #{format_with_commas(@total_fuel_burned)} liters"
    puts "  Flight time: #{@total_flight_time.strftime('%-H:%M:%S')}"
  end

  def check_rocket_status
    #Abort 1 of every 3
    3.in(10) do
      return 'abort'
    end
    #Explode 1 every 5
    2.in(10) do
      return 'explode'
    end
  end

  private

  def handle_explosion
    puts 'Rocket Exploded!'
    update_totals(@current_distance, @t)
    'exploded'
  end

  def finish_mission_status(aborts, retries_explosions)
    @current_distance += 10
    @t += 25
    update_totals
    mission_summary(aborts, retries_explosions[0], retries_explosions[1])
  end

  def retrieve_iteration_to_explode(will_explode)
    if will_explode == 'explode_during_launch'
      rand(12)
    else
      -1
    end
  end

  def update_totals
    @total_distance += @current_distance
    @total_fuel_burned += convert_to_seconds(@t) * (168_240 / 60)
    @total_flight_time = Time.new(0) + (convert_to_seconds(@total_flight_time) \
    + convert_to_seconds(@t))
  end

  def convert_to_seconds(tme)
    (tme.hour * 60 * 60 + tme.min * 60 + tme.sec)
  end

  def handle_mission_status
    @current_distance += 12.5
    @t += 30
    #Assumed current speed would vary in either direction
    #by 20%, made assumption by looking at other branch
    current_speed = rand(1200..1800)
    burn_rate = retrieve_burn_rate(current_speed)
    time_to_dest = retrieve_time_to_dest
    puts 'Mission status:'
    print_mission_status(burn_rate, format_with_commas(current_speed),\
                         time_to_dest)
  end

  def retrieve_time_to_dest
    total_time_to_dest = Time.new(0) + 385
    time_diff = total_time_to_dest - @t
    Time.new(0) + time_diff
  end

  def retrieve_burn_rate(current_speed)
    burn_rate = (current_speed.fdiv(1500) * 168_240).to_i
    format_with_commas(burn_rate)
  end

  def format_with_commas(str)
    str.to_s.reverse.gsub(/(\d{3})/, '\\1,').chomp(',').reverse
  end

  def mission_plan_data
    { 'Travel distance:' => "  #{@distance} km", \
      'Payload capacity:' => " #{@payload} kg",
      'Fuel capacity:' => "    #{@capacity} liters", \
      'Burn rate:' => "        #{@burn_rate} liters/min",
      'Average speed:' => "    #{@avg_speed} km/h" }
  end
end
