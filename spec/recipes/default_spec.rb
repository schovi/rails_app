require_relative '../spec_helper'

describe 'rubygems_app::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'installs user' do
    expect(chef_run).to install_package('user')
  end

  it 'creates user' do
    expect(chef_run).to create_user('rubygems_app')
  end

  it 'creates app directory' do
    expect(chef_run).to create_directory('/home/rubygems_app')
  end

end
