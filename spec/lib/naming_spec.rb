require 'rails_helper'

describe Garden::Naming do
  it "parses various originals" do
    [ NaturalDocketSeed, :natural_docket_seed, :natural_docket_seeds,
      NaturalDocket, :natural_docket, :natural_dockets,
      NaturalDocketSerializer, :natural_docket_serializer,
      NaturalDocketSeedSerializer, :natural_docket_seed_serializer
    ].each do |original|
      Garden::Naming.new(original).base.should == 'natural_docket'
    end
  end

  it "generates various inflections" do
      n = Garden::Naming.new('natural_dockets')
      n.base.should == 'natural_docket'
      n.fruit.should == 'NaturalDocket'
      n.seed.should == 'NaturalDocketSeed'
      n.plural.should == 'natural_dockets'
      n.seed_plural.should == 'natural_docket_seeds'
      n.serializer.should == 'NaturalDocketSerializer'
      n.seed_serializer.should == 'NaturalDocketSeedSerializer'
  end
end
