#! /usr/bin/env ruby
require 'spec_helper'

require 'puppet/reports'

tagmail = Puppet::Reports.report(:tagmail)

describe tagmail do
  let(:processor) do
    processor = Puppet::Transaction::Report.new('apply')
    processor.extend(Puppet::Reports.report(:tagmail))
  end

  passers = my_fixture 'tagmail_passers.conf'
  File.readlines(passers).each do |line|
    it "should be able to parse '#{line.inspect}'" do
      processor.parse_tagmap(line)
    end
  end

  failers = my_fixture 'tagmail_failers.conf'
  File.readlines(failers).each do |line|
    it "should not be able to parse '#{line.inspect}'" do
      -> { processor.parse_tagmap(line) }.should raise_error(ArgumentError)
    end
  end

  {
    'tag: abuse@domain.com' => [['abuse@domain.com'], ['tag'], []],
    'tag.localhost: abuse@domain.com' => [['abuse@domain.com'], ['tag.localhost'], []],
    'tag, other: abuse@domain.com' => [['abuse@domain.com'], ['tag', 'other'], []],
    'tag-other: abuse@domain.com' => [['abuse@domain.com'], ['tag-other'], []],
    'tag, !other: abuse@domain.com' => [['abuse@domain.com'], ['tag'], ['other']],
    'tag, !other, one, !two: abuse@domain.com' => [['abuse@domain.com'], ['tag', 'one'], ['other', 'two']],
    'tag: abuse@domain.com, other@domain.com' => [['abuse@domain.com', 'other@domain.com'], ['tag'], []],

  }.each do |line, results|
    it "should parse '#{line}' as #{results.inspect}" do
      processor.parse_tagmap(line).shift.should == results
    end
  end

  describe 'when matching logs' do
    before(:each) do
      processor << Puppet::Util::Log.new(level: :notice, message: 'first', tags: ['one'])
      processor << Puppet::Util::Log.new(level: :notice, message: 'second', tags: ['one', 'two'])
      processor << Puppet::Util::Log.new(level: :notice, message: 'third', tags: ['one', 'two', 'three'])
    end

    def match(pos = [], neg = [])
      pos = Array(pos)
      neg = Array(neg)
      result = processor.match([[['abuse@domain.com'], pos, neg]])
      actual_result = result.shift
      if actual_result
        actual_result[1]
      else
        nil
      end
    end

    it "matches all messages when provided the 'all' tag as a positive matcher" do
      results = match('all')
      ['first', 'second', 'third'].each do |str|
        results.should be_include(str)
      end
    end

    it 'removes messages that match a negated tag' do
      match('all', 'three').should_not be_include('third')
    end

    it 'finds any messages tagged with a provided tag' do
      results = match('two')
      results.should be_include('second')
      results.should be_include('third')
      results.should_not be_include('first')
    end

    it 'allows negation of specific tags from a specific tag list' do
      results = match('two', 'three')
      results.should be_include('second')
      results.should_not be_include('third')
    end

    it 'allows a tag to negate all matches' do
      results = match([], 'one')
      results.should be_nil
    end
  end

  describe 'the behavior of tagmail.process' do
    let(:processor) do
      processor = Puppet::Transaction::Report.new('apply')
      processor.extend(Puppet::Reports.report(:tagmail))
      processor
    end

    context 'when any messages match a positive tag' do
      before(:each) do
        processor << log_entry
      end

      let(:log_entry) do
        Puppet::Util::Log.new(
          level: :notice, message: 'Secure change', tags: ['secure'],
        )
      end

      let(:message) do
        "#{log_entry.time} Puppet (notice): Secure change"
      end

      it 'sends email if there are changes' do
        allow(processor).to receive(:send).with([[['user@domain.com'], message]])
        allow(processor).to receive(:raw_summary).and_return('resources' => { 'changed' => 1, 'out_of_sync' => 0 }, 'events' => { 'audit' => nil })

        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'sends email if there are resources out of sync' do
        allow(processor).to receive(:send).with([[['user@domain.com'], message]])
        allow(processor).to receive(:raw_summary).and_return('resources' => { 'changed' => 0, 'out_of_sync' => 1 }, 'events' => { 'audit' => nil })

        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'sends email if there are audit failure' do
        allow(processor).to receive(:send).with([[['user@domain.com'], message]])
        allow(processor).to receive(:raw_summary).and_return('resources' => { 'changed' => 1, 'out_of_sync' => 0 }, 'events' => { 'audit' => 1 })

        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'does not send email if no changes or resources out of sync or no audit failure' do
        allow(processor).to receive(:send).never
        allow(processor).to receive(:raw_summary).and_return('resources' => { 'changed' => 0, 'out_of_sync' => 0 }, 'events' => { 'audit' => nil })

        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'logs a message if no changes or resources out of sync or no audit failure' do
        allow(processor).to receive(:send).never
        allow(processor).to receive(:raw_summary).and_return('resources' => { 'changed' => 0, 'out_of_sync' => 0 }, 'events' => { 'audit' => nil })

        expect(Puppet).to receive(:notice).with('Not sending tagmail report; no changes')
        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'sends email if raw_summary is not defined' do
        allow(processor).to receive(:send).with([[['user@domain.com'], message]])
        allow(processor).to receive(:raw_summary).and_return(nil)
        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'sends email if there are no resource metrics' do
        allow(processor).to receive(:send).with([[['user@domain.com'], message]])
        allow(processor).to receive(:raw_summary).and_return('resources' => nil)
        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'sends email if there are no events metrics' do
        allow(processor).to receive(:send).with([[['user@domain.com'], message]])
        allow(processor).to receive(:raw_summary).and_return('events' => nil)
        processor.process(my_fixture('tagmail_email.conf'))
      end
    end

    context 'when no message match a positive tag' do
      before(:each) do
        processor << log_entry
      end

      let(:log_entry) do
        Puppet::Util::Log.new(
          level: :notice,
          message: 'Unnotices change',
          tags: ['not_present_in_tagmail.conf'],
        )
      end

      it 'sends no email if there are changes' do
        allow(processor).to receive(:send).never
        allow(processor).to receive(:raw_summary).and_return('resources' => { 'changed' => 1, 'out_of_sync' => 0 }, 'events' => { 'audit' => nil })
        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'sends no email if there are resources out of sync' do
        allow(processor).to receive(:send).never
        allow(processor).to receive(:raw_summary).and_return('resources' => { 'changed' => 0, 'out_of_sync' => 1 }, 'events' => { 'audit' => nil })
        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'sends no email if there are audit failure' do
        allow(processor).to receive(:send).never
        allow(processor).to receive(:raw_summary).and_return('resources' => { 'changed' => 0, 'out_of_sync' => 0 }, 'events' => { 'audit' => 1 })

        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'sends no email if no changes or resources out of sync or no audit failure' do
        allow(processor).to receive(:send).never
        allow(processor).to receive(:raw_summary).and_return('resources' => { 'changed' => 0, 'out_of_sync' => 0 }, 'events' => { 'audit' => nil })
        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'sends no email if raw_summary is not defined' do
        allow(processor).to receive(:send).never
        allow(processor).to receive(:raw_summary).and_return(nil)
        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'sends no email if there are no resource metrics' do
        allow(processor).to receive(:send).never
        allow(processor).to receive(:raw_summary).and_return('resources' => nil)
        processor.process(my_fixture('tagmail_email.conf'))
      end

      it 'sends no email if there are no events metrics' do
        allow(processor).to receive(:send).never
        allow(processor).to receive(:raw_summary).and_return('events' => nil)
        processor.process(my_fixture('tagmail_email.conf'))
      end
    end
  end
end
