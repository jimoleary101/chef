#
# Author:: Lamont Granquist (lamont@opscode.com)
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe Chef::Provider::RegistryKey do

  let(:testval1) { { :name => "one", :type => :string, :data => "1" } }
  let(:testval2) { { :name => "two", :type => :string, :data => "2" } }

  before(:each) do
    @node = Chef::Node.new
    @events = Chef::EventDispatch::Dispatcher.new
    @run_context = Chef::RunContext.new(@node, {}, @events)

    @new_resource = Chef::Resource::RegistryKey.new("windows is fun", @run_context)
    @new_resource.key 'HKLM\Software\Opscode\Testing'
    @new_resource.values( testval1 )
    @new_resource.recursive false

    @provider = Chef::Provider::RegistryKey.new(@new_resource, @run_context)

    @provider.stub!(:running_on_windows!).and_return(true)
    @double_registry = double(Chef::Win32::Registry)
    @provider.stub!(:registry).and_return(@double_registry)
  end

  describe "when first created" do
  end

  describe "executing load_current_resource" do
    describe "when the key exists" do
      before(:each) do
        @double_registry.should_receive(:key_exists?).with("HKLM\\Software\\Opscode\\Testing").and_return(true)
        @double_registry.should_receive(:get_values).with("HKLM\\Software\\Opscode\\Testing").and_return( testval2 )
        @provider.load_current_resource
      end

      it "should set the key of the current resource to the key of the new resource" do
        @provider.current_resource.key.should == @new_resource.key
      end

      it "should set the architecture of the current resource to the architecture of the new resource" do
        @provider.current_resource.architecture.should == @new_resource.architecture
      end

      it "should set the recursive flag of the current resource to the recursive flag of the new resource" do
        @provider.current_resource.recursive.should == @new_resource.recursive
      end

      it "should set the values of the current resource to the values it got from the registry" do
        @provider.current_resource.values.should == [ testval2 ]
      end
    end

    describe "when the key does not exist" do
      before(:each) do
        @double_registry.should_receive(:key_exists?).with("HKLM\\Software\\Opscode\\Testing").and_return(false)
        @provider.load_current_resource
      end

      it "should set the values in the current resource to nil" do
        @provider.current_resource.values.should == nil
      end
    end
  end

  describe "action_create" do
  end

  describe "action_create_if_missing" do
  end

  describe "action_delete" do
  end

  describe "action_delete_key" do
  end

end
