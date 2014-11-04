require 'spec_helper'

describe Project do
  it 'has a valid factory' do
    expect(build :project).to be_valid
  end

  describe 'validations' do
    it 'is invalid without a name' do
      expect(build :project, name: nil).to be_invalid
    end
  end

  describe 'associations' do
    let(:project) { Project.new }

    it 'responds to issues' do
      expect(project).to respond_to(:issues)
    end

    it 'responds to issues=' do
      expect(project).to respond_to(:issues=)
    end
  end

  describe 'default scope' do
    it 'orders the projects by name ASC' do
      pro1 = create :project, name: 'Testprojekt'
      pro2 = create :project, name: 'AProjekt'

      expect(Project.all).to eq([pro2, pro1])
    end
  end
end