require 'uri'
require 'open-uri'
require 'zip'

class ElectionData
  INTERESTING_FILES = '*00R.xml'

  attr_reader :uri, :tempfile
  def initialize(url = ENV['ELECTION_DATA_URL'])
    @uri = http_uri_from url
  end

  def zip_from_election_authority
    @tempfile ||= open uri
  end

  def unzip
    return unless zip_from_election_authority
    @xml_files ||= unzip_interesting_files
  end

  def parse

  end

  private
  def http_uri_from(url)
    URI.parse(url).tap do |uri|
      raise URI::InvalidURIError unless uri.kind_of? URI::HTTP
    end
  rescue URI::InvalidURIError
    raise "Env ELECTION_DATA_URL does not contain an http URL."
  end

  def unzip_interesting_files
    Zip::File.open(zip_from_election_authority) do |zipped_files|
      zipped_files.glob(INTERESTING_FILES).map do |entry|
        extract_to_tempfile entry
      end
    end
  ensure
    zip_from_election_authority.close
    zip_from_election_authority.unlink
  end

  def extract_to_tempfile(entry)
    filename = File.basename entry.name
    xml_file = Tempfile.new filename
    xml_file.binmode
    xml_file.write entry.get_input_stream.read
    xml_file
  end
end
