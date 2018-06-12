require './mission_plan'

# RocketLaunch Helper
module RocketLaunchHelper
  def handle_rocket_status
    case @method_status[1]
    when 'abort'
      handle_abort
    when 'explode'
      handle_explode
    end
    mission_summary_new_mission
  end

  def handle_abort
    puts 'Mission aborted!'
    @aborts += 1
  end

  def handle_explode
    puts 'Rocket exploded!'
    @explosions += 1
  end

  def mission_summary_new_mission
    @mission.mission_summary(@aborts, @retries, @explosions)
    new_mission
  end

  def new_mission
    print 'Would you like to run another mission? (Y/n) '
    input = gets.chomp
    if input =~ /(y|Y)/
      @retries += 1
      launch_sequence
    else
      puts 'Mission Over'
    end
  end
end

# Helps handle the rocket launch
class RocketLaunch
  attr_reader :mission
  include RocketLaunchHelper

  def self.start_mission(distance, payload, capacity, burn_rate, avg_speed)
    new(distance, payload, capacity, burn_rate, avg_speed).launch_sequence
  end

  def initialize(distance, payload, capacity, brn_rate, avg_speed)
    @mission = MissionPlan.new(distance, payload, capacity, brn_rate, avg_speed)
    @aborts = 0
    @retries = 0
    @explosions = 0
    @method_status = []
  end

  def launch_sequence
    retrieve_rocket_status
    puts 'Welcome to Mission Control!'
    puts 'Mission plan:'
    @mission.mission_details
    print 'What is the name of this mission? '
    gets.chomp
    print 'Would you like to proceed? (Y/n) '
    launch_process(gets.chomp, 'afterburner', nil)
  end

  private

  def launch_process(input, step, message)
    if input =~ /(y|Y)/
      puts message unless message.nil?
      if step == 'mission_status'
        lp_status_or_explosion
      else
        send(step)
      end
    else
      lp_abort
    end
  end

  def lp_status_or_explosion
    if @method_status[0] == 'mission_status'
      handle_rocket_status
    else
      lp_explosion
    end
  end

  def lp_explosion
    if @mission.mission_status(@aborts, @retries, \
                               @explosions, @method_status[0]) == 'exploded'
      @explosions += 1
      @mission.mission_summary(@aborts, @retries, @explosions)
    end
    new_mission
  end

  def lp_abort
    puts 'Mission aborted!'
    @aborts += 1
    @mission.mission_summary(@aborts, @retries, @explosions)
    new_mission
  end

  def afterburner
    print 'Engage afterburner? (Y/n) '
    launch_process(gets.chomp, 'disengage', 'Afterburner engaged!')
  end

  def disengage
    if __method__.to_s == @method_status[0]
      handle_rocket_status
    else
      print 'Release support structures? (Y/n) '
      launch_process(gets.chomp, 'cross_checks', 'Support structures released!')
    end
  end

  def cross_checks
    if __method__.to_s == @method_status[0]
      handle_rocket_status
    else
      print 'Perform cross-checks? (Y/n) '
      launch_process(gets.chomp, 'launch', 'Cross-checks performed!')
    end
  end

  def launch
    if __method__.to_s == @method_status[0]
      handle_rocket_status
    else
      print 'Launch? (Y/n) '
      launch_process(gets.chomp, 'mission_status', 'Launched!')
    end
  end

  def retrieve_rocket_status
    rocket_status = @mission.check_rocket_status
    if rocket_status == 'abort'
      @method_status = [%w[disengage cross_checks launch \
                           mission_status][rand(4)], rocket_status]
    elsif rocket_status == 'explode'
      @method_status = [%w[disengage cross_checks launch mission_status \
                           explode_during_launch]\
                        [rand(5)], rocket_status]
    end
  end
end

RocketLaunch.start_mission(160, 50_000, 1_514_100, 168_240, 1500)
