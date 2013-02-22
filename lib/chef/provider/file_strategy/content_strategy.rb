#
# Author:: Lamont Granquist (<lamont@opscode.com>)
# Copyright:: Copyright (c) 2013 Opscode, Inc.
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

class Chef
  class Provider
    class FileStrategy
      class ContentStrategy
        attr_accessor :run_context

        def initialize(new_resource, current_resource, run_context)
          @new_resource = new_resource
          @current_resource = current_resource
          @run_context = run_context
        end

        def contents_changed?
          !checksum.nil? && checksum != @current_resource.checksum
        end

        def tempfile
          raise "class must implement tempfile!"
        end

        def checksum
          return nil if tempfile.nil? || tempfile.path.nil?
          Chef::Digester.checksum_for_file(tempfile.path)
        end

        def cleanup
          tempfile.unlink unless tempfile.nil?
        end
      end
    end
  end
end
