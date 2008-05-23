#!/usr/bin/env ruby
 
require File.dirname(__FILE__) + '/../../../spec_helper'

require 'puppet/parser/functions/template_version.rb'

describe Puppet::Parser::Functions do
  it 'should povide :template_version' do
    Puppet::Parser::Functions.functions.include?(:template_version).should == true
  end
  it 'should define function_template_version in scope' do
    Puppet::Parser::Scope.method_defined?('function_template_version').should == true
  end
  describe 'when called with invalid arguments' do
    it 'should raise an error when the version is missing' do
      @scope = Puppet::Parser::Scope.new
      proc { @scope.function_template_version([]) }.should raise_error(Puppet::ParseError)
    end
    it 'should raise an error when the mapping is missing' do
      @scope = Puppet::Parser::Scope.new
      proc { @scope.function_template_version(['1.0.0']) }.should raise_error(Puppet::ParseError)
    end
  end
  it 'should determine the template version when a matching version was provided' do
    @scope = Puppet::Parser::Scope.new
    @scope.function_template_version(['1.0.0', '1.0.0:1.0.0']).should == '1.0.0'
    @scope.function_template_version(['1.1.0', '1.0.0@1.1.0:1.0.0']).should == '1.0.0'
    @scope.function_template_version(['2.0.0', '1.0.0@1.1.0:1.0.0,2.0.0:2.0.0']).should == '2.0.0'
  end
end
