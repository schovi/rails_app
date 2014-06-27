require_relative '../spec_helper'

describe 'rails_app::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'installs user' do
    expect(chef_run).to install_package('user')
  end

  it 'creates user' do
    expect(chef_run).to create_user('rails_app')
  end

  it 'creates app directory' do
    expect(chef_run).to create_directory('/home/rails_app')
  end

end
