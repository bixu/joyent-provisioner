require 'spec_helper'
require 'provisioner'

describe Provisioner::Command::Provision do
  let(:configuration) { Provisioner::Configuration.from_path('spec/fixtures/test.yml') }

  describe '#shell_commands' do

    context 'host is specified' do

      let(:subject) { Provisioner::Command::Provision.new(template_configuration, '1') }
      let(:expected_command) { [
          'knife joyent server create',
          '--image 9ec5c0c-a941-11e2-a7dc-57a6b041988f',
          '--flavor g3-highmemory-17.125-smartos',
          '--distro smartos-base64',
          '--networks 42325ea0-eb62-44c1-8eb6-0af3e2f83abc,c8cde927-6277-49ca-82a3-741e8b23b02f',
          '--environment test',
          '--node-name memcached-sessions001.test',
          '--run-list role[joyent]',
          '2>&1 > ./tmp/memcached-sessions001.test_provision.log &'
      ].join(' ') }

      context 'passing options directly' do
        let(:template_configuration) { {
            image: '9ec5c0c-a941-11e2-a7dc-57a6b041988f',
            flavor: 'g3-highmemory-17.125-smartos',
            distro: 'smartos-base64',
            networks: '42325ea0-eb62-44c1-8eb6-0af3e2f83abc,c8cde927-6277-49ca-82a3-741e8b23b02f',
            host_sequence: '1..2',
            host_suffix: 'test',
            host_prefix: 'memcached-sessions',
            environment: 'test',
            log_dir: './tmp',
            run_list: 'role[joyent]'
        } }
        it 'returns expected command string' do
          expect(subject.shell_commands).to eq([expected_command])
        end
      end

      context 'using the template from yaml configuration' do
        let(:template_configuration) { configuration.for_template('memcached-sessions') }

        it 'returns expected command string' do
          expect(subject.shell_commands).to eq([expected_command])
        end
      end
    end

    context 'host number is not specified' do
      let(:subject) { Provisioner::Command::Provision.new(template_configuration) }
      let(:template_configuration) { configuration.for_template('memcached-sessions') }

      it 'returns an array of commands based on the configuration' do
        commands = subject.shell_commands
        expect(commands).to be_an(Array)
        expect(commands.size).to be(2)
        expect(commands[0]).to include('--node-name memcached-sessions001.test')
        expect(commands[1]).to include('--node-name memcached-sessions002.test')
      end
    end
  end
end