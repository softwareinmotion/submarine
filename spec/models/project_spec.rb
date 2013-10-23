require 'spec_helper'

describe Project do
  it 'has a valid factory' do
    create(:project).should be_valid
  end

  it 'can only be created with a present name' do
    build(:project, name: nil).should_not be_valid
  end
end