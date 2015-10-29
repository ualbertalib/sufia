module Sufia
  module Permissions
    module Readable
      extend ActiveSupport::Concern

      def public?
        read_groups.include?('public')
      end

      def registered?
        read_groups.include?('registered')
      end

      def private?
        !(public? || registered?)
      end

      def embargoed?
        self.respond_to?(:under_embargo?) && self.under_embargo?
      end
    end
  end
end
