require 'active_fedora'

module CommonRepositoryModel
  class MetadataDatastream < ActiveFedora::NomDatastream

    def self.not_available_date
      @not_available_date ||= Date.new(9999,12,31).freeze
    end

    def self.text_accessor
      lambda { |x| x.text.to_s.strip }
    end

    def self.date_accessor
      lambda { |x|
        date = x.text.to_s.strip
        if date.empty?
          not_available_date
        else
          Date.parse(date)
        end
      }
    end

  end
end
