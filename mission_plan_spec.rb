require_relative 'mission_plan.rb'
require 'pry'

describe MissionPlan do
  let(:mission) { MissionPlan.new(160, 50_000, 1_514_100, 168_240, 1500)}

  it "should return model attributes from inputs" do
    expect(mission.avg_speed).to eq "1,500"
    expect(mission.burn_rate).to eq "168,240"
    expect(mission.capacity).to eq "1,514,100"
    expect(mission.distance).to eq 160.0
  end

  it "should print mission details" do
    details = mission.mission_details
    expect(details["Travel distance:"]).to eq "  160.0 km"
    expect(details["Payload capacity:"]).to eq " 50,000 kg"
    expect(details["Fuel capacity:"]).to eq "    1,514,100 liters"
    expect(details["Burn rate:"]).to eq "        168,240 liters/min"
    expect(details["Average speed:"]).to eq "    1,500 km/h"
  end

  it "should return misson status" do
    expect(mission.mission_status(0,0,0,0)).to eq nil
  end

  it "should return mission summary" do
    expect(mission.mission_summary(0,0,0)).to eq nil
  end
end

