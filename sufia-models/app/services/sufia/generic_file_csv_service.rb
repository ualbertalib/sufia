module Sufia
  #
  # Generates CSV from a Generic_File
  #
  # @attr_reader [GenericFile] generic_file file that will be examined to generate the CSVs
  # @attr_reader [Array] terms list of terms that will be output in CSV form
  # @attr_reader [String] multi_value_separator separator for terms that have more than one value
  class GenericFileCSVService
    attr_reader :generic_file, :terms, :multi_value_separator

    # @param [GenericFile] generic_file file that will be examined to generate the CSVs
    # @param [Array]       terms list of terms that will be output in CSV form
    #                      defaults if nil to list below
    # @param [String]      multi_value_separator separator for terms that have more than one value
    #                      defaults to '|'
    def initialize(file, terms = nil, multi_value_separator = '|')
      @generic_file = file
      @terms = terms
      @terms ||= [:id, :title, :depositor, :creator, :visibility, :resource_type, :rights, :file_format]
      @multi_value_separator = multi_value_separator
    end

    # provide csv version of the GenericFile
    def csv
      ::CSV.generate do |csv|
        csv << terms.map do |term|
          values = generic_file.send(term)
          values = Array(values) # make sure we have an array
          values.join(multi_value_separator)
        end
      end
    end

    # provide csv header line for a GenericFile
    def csv_header
      ::CSV.generate do |csv|
        csv << terms
      end
    end
  end
end
