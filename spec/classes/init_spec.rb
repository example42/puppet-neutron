require 'spec_helper'

describe 'neutron' do

  context 'Supported OS - ' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "#{osfamily} standard installation" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it { should contain_package('neutron').with_ensure('present') }
        it { should contain_service('neutron').with_ensure('running') }
      end

      describe "#{osfamily} installation of a specific package version" do
        let(:params) { {
          :package_ensure => '1.0.42',
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it { should contain_package('neutron').with_ensure('1.0.42') }
      end

      describe "#{osfamily} removal of package installation" do
        let(:params) { {
          :package_ensure => 'absent',
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it 'should remove Package[neutron]' do should contain_package('neutron').with_ensure('absent') end
        it 'should stop Service[neutron]' do should contain_service('neutron').with_ensure('stopped') end
        it 'should not manage at boot Service[neutron]' do should contain_service('neutron').with_enable(nil) end
        it 'should remove neutron configuration file' do should contain_file('neutron.conf').with_ensure('absent') end
      end

      describe "#{osfamily} service disabling" do
        let(:params) { {
          :service_ensure => 'stopped',
          :service_enable => false,
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it 'should stop Service[neutron]' do should contain_service('neutron').with_ensure('stopped') end
        it 'should not enable at boot Service[neutron]' do should contain_service('neutron').with_enable('false') end
      end

      describe "#{osfamily} configuration via custom template" do
        let(:params) { {
          :config_file_template     => 'neutron/spec.conf',
          :config_file_options_hash => { 'opt_a' => 'value_a' },
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it { should contain_file('neutron.conf').with_content(/This is a template used only for rspec tests/) }
        it 'should generate a template that uses custom options' do
          should contain_file('neutron.conf').with_content(/value_a/)
        end
      end

      describe "#{osfamily} configuration via custom content" do
        let(:params) { {
          :config_file_content    => 'my_content',
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it { should contain_file('neutron.conf').with_content(/my_content/) }
      end

      describe "#{osfamily} configuration via custom source file" do
        let(:params) { {
          :config_file_source => "puppet:///modules/neutron/spec.conf",
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it { should contain_file('neutron.conf').with_source('puppet:///modules/neutron/spec.conf') }
      end

      describe "#{osfamily} configuration via custom source dir" do
        let(:params) { {
          :config_dir_source => 'puppet:///modules/neutron/tests/',
          :config_dir_purge => true
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it { should contain_file('neutron.dir').with_source('puppet:///modules/neutron/tests/') }
        it { should contain_file('neutron.dir').with_purge('true') }
        it { should contain_file('neutron.dir').with_force('true') }
      end

      describe "#{osfamily} service restart on config file change (default)" do
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it 'should automatically restart the service when files change' do
          should contain_file('neutron.conf').with_notify('Service[neutron]')
        end
      end

      describe "#{osfamily} service restart disabling on config file change" do
        let(:params) { {
          :config_file_notify => '',
        } }
        let(:facts) {{
          :osfamily => osfamily,
        }}
        it 'should automatically restart the service when files change' do
          should contain_file('neutron.conf').without_notify
        end
      end

    end
  end

  context 'Unsupported OS - ' do
    describe 'Not supported operating systems should throw and error' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { should }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end

end

