class Gnip::Payload

    attr_reader :body, :raw_value, :title, :mediaURLs

    def initialize(raw, body = nil, title = nil, mediaURLs = [])
        @raw_value = Gnip::Payload.encode(raw)
        @body = body
        @title = title
        @mediaURLs = mediaURLs
    end


    def to_xml()
        XmlSimple.xml_out(self.to_hash, {'RootName' => ''})
    end

    def to_hash()
        result = {}
        result['body'] = [@body]
        result['raw'] = [@raw_value]  if @raw_value
        result['mediaURL'] = @mediaURLs if @mediaURLs
        result
    end

    def ==(another)
        another.instance_of?(self.class) && another.body == @body && another.raw == @raw_value
    end
    alias eql? ==

    def raw
        Gnip::Payload.decode(@raw_value) if @raw_value
    end

    def self.from_hash(hash)
        return if hash.nil?  || hash.empty?
        title = hash['title'].first if hash['title']
        body = hash['body'].first if hash['body']
        raw = decode(hash['raw'].first) if hash['raw'] 
        mediaURLs = hash['mediaURL'] if hash['mediaURL']
        Gnip::Payload.new(raw, body, title, mediaURLs)
    end

    def self.from_xml(document)
        hash = XmlSimple.xml_in(document)
        self.from_hash(hash)
    end

    class Gnip::Payload::Builder

        def initialize(raw)
            @raw = raw
            @mediaURLs = []
        end

        def title(title)
            @title = title
            self
        end

        def body(body)
            @body = body
            self
        end

        def mediaURLs(mediaURLs)
            @mediaURLs = mediaURLs
            self
        end

        def mediaURL(mediaURL, height=nil, width=nil, duration=nil, mimeType=nil, type=nil)
            mediaURL = { "content" => mediaURL }
            mediaURL.merge!("height"    => height)    if height
            mediaURL.merge!("width"     => width)     if width
            mediaURL.merge!("duration"  => duration)  if duration
            mediaURL.merge!("mimeType"  => mimeType)  if mimeType
            mediaURL.merge!("type"      => type)      if type
            
            @mediaURLs.push(mediaURL)
            self
        end

        def build
            Gnip::Payload.new(@raw, @body, @title, @mediaURLs)
        end
    end

    private

    def self.encode(some_string)
        result = StringIO.new()
        gzip_writer = Zlib::GzipWriter.new(result)
        gzip_writer.write(some_string)
        gzip_writer.close
        Base64.encode64(result.string)
    end

    def self.decode(raw)
        Zlib::GzipReader.new(StringIO.new(Base64.decode64(raw))).read
    end

end
