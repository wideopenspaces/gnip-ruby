class Gnip::Connection < Gnip::Base

    def initialize(config)
        @gnip_config = config
    end

    def server_time
        result = head("/")
        Time.httpdate(result['Date']).gmtime
    end

    # Logger for this connection.
    def logger
        @gnip_config.logger
    end

    # Config object for this connection.
    def config
        @gnip_config
    end


    #Publish a activity xml document to gnip for a give publisher
    #You must be the owner of the publisher to publish
    #activities_xml is the xml stream of gnip activities
    def publish_xml(publisher, activity_xml)
        logger.info("Publishing activities for #{publisher.name}")
        publisher_path = "#{publisher.uri}/activity.xml"
        post(publisher_path, activity_xml)
    end

    #Publish a activity xml document to gnip for a give publisher
    #You must be the owner of the publisher to publish
    #activity_list is an array of activity objects
    def publish(publisher, activity_list)
        logger.info("Publishing activities for #{publisher.name}")
        publisher_path = "#{publisher.uri}/activity.xml"
        post(publisher_path, Gnip::Activity.list_to_xml(activity_list))
    end

    # Gets the current activities for a publisher
    # Time is the time object. If nil, then the server returns the current bucket
    def publisher_activities_stream_xml(publisher, time = nil)
        timestamp = time ? time.to_gnip_bucket_id : 'current'
        logger.info("Timestamp for #{time} is #{timestamp}")
        logger.info("Getting activities xml for #{publisher.name} at #{timestamp}")
        get("#{publisher.uri}/activity/#{timestamp}.xml")
    end

    # Gets the current activities for a publisher
    # Time is the time object. If nil, then the server returns the current bucket
    def publisher_activities_stream(publisher, time = nil)
        timestamp = time ? time.to_gnip_bucket_id : 'current'
        logger.info("Timestamp for #{time} is #{timestamp}")
        logger.info("Getting activities for #{publisher.name} at #{timestamp}")
        response, activities_xml = get("#{publisher.uri}/activity/#{timestamp}.xml")
        activities = []
        activities = Gnip::Activity.list_from_xml(activities_xml) if response.code == '200'
        return [response, activities]
    end  
    alias_method :get_publisher_activities, :publisher_activities_stream

    # Gets the current activities for a filter
    # Time is the time object. If nil, then the server returns the current bucket
    def filter_activities_stream_xml(publisher, filter, time = nil)
        timestamp = time ? time.to_gnip_bucket_id : 'current'
        logger.info("Timestamp for #{time} is #{timestamp}")
        logger.info("Getting activities xml for #{filter.name} at #{timestamp}")
        get("#{publisher.uri}/#{filter.uri}/#{filter.name}/activity/#{timestamp}.xml")
    end

    # Gets the current activities for a filter
    # Time is the time object. If nil, then the server returns the current bucket
    def filter_activities_stream(publisher, filter, time = nil)
        timestamp = time ? time.to_gnip_bucket_id : 'current'
        logger.info("Timestamp for #{time} is #{timestamp}")
        logger.info("Getting activities for #{filter.name} at #{timestamp}")
        response, activities_xml = get("#{publisher.uri}/#{filter.uri}/#{filter.name}/activity/#{timestamp}.xml")
        activities = []
        activities = Gnip::Activity.list_from_xml(activities_xml) if response.code == '200'
        return [response, activities]
    end
    alias_method :get_filter_activities, :filter_activities_stream
    

    # Gets the current notifications for a publisher
    # Time is the time object. If nil, then the server returns the current bucket
    def publisher_notifications_stream_xml(publisher, time = nil)
        timestamp = time ? time.to_gnip_bucket_id : 'current'
        logger.info("Timestamp for #{time} is #{timestamp}")
        logger.info("Getting activities xml for #{publisher.name} at #{timestamp}")
        get("#{publisher.uri}/notification/#{timestamp}.xml")
    end

    # Gets the current notifications for a publisher
    # Time is the time object. If nil, then the server returns the current bucket
    def publisher_notifications_stream(publisher, time = nil)
        timestamp = time ? time.to_gnip_bucket_id : 'current'
        logger.info("Timestamp for #{time} is #{timestamp}")
        logger.info("Getting activities for #{publisher.name} at #{timestamp}")
        response, activities_xml = get("#{publisher.uri}/notification/#{timestamp}.xml")
        activities = []
        activities = Gnip::Activity.list_from_xml(activities_xml) if response.code == '200'
        return [response, activities]
    end
    alias_method :get_publisher_notifications, :publisher_notifications_stream
    
    # Gets the current notifications for a filter
    # Time is the time object. If nil, then the server returns the current bucket
    def filter_notifications_stream_xml(publisher, filter, time = nil)
        timestamp = time ? time.to_gnip_bucket_id : 'current'
        logger.info("Timestamp for #{time} is #{timestamp}")
        logger.info("Getting activities xml for #{filter.name} at #{timestamp}")
        get("#{publisher.uri}/#{filter.uri}/#{filter.name}/notification/#{timestamp}.xml")
    end

    # Gets the current notifications for a filter
    # Time is the time object. If nil, then the server returns the current bucket
    def filter_notifications_stream(publisher, filter, time = nil)
        timestamp = time ? time.to_gnip_bucket_id : 'current'
        logger.info("Timestamp for #{time} is #{timestamp}")
        logger.info("Getting activities for #{filter.name} at #{timestamp}")
        response, activities_xml = get("#{publisher.uri}/#{filter.uri}/#{filter.name}/notification/#{timestamp}.xml")
        activities = []
        activities = Gnip::Activity.list_from_xml(activities_xml) if response.code == '200'
        return [response, activities]
    end
    alias_method :get_filter_notifications, :filter_notifications_stream

    def get_filter(publisher, filter_name)
        logger.info("Getting filter #{filter_name}")
        find_path = "#{publisher.uri}/filters/#{filter_name}.xml"
        response, data = get(find_path)
        filter = nil
        if (response.code == '200')
            filter = Gnip::Filter.from_xml(data)
        end
        return [response, filter]
    end

    def get_publisher(publisher_name, publisher_scope = 'my')
        logger.info("Getting publisher #{publisher_name}")
        get_path = "/#{publisher_scope}/publishers/#{publisher_name}.xml"
        response, data = get(get_path)
        publisher = nil
        if (response.code == '200')
            publisher = Gnip::Publisher.from_xml(data, publisher_scope)
        else 
            logger.info("Received error response #{response.code}")
        end
        return [response, publisher]
    end

    def get_publishers()
        logger.info('Getting publisher list')
        get_path = '/my/publishers.xml'
        response, data = get(get_path)
        publishers = []
        if (response.code == '200')
            publishers = Gnip::Connection.publishers_from_xml(data)
        end
        return [response, publishers]
    end

    def create_publisher(publisher)
        logger.info("Creating #{publisher.class} with name #{publisher.name}")
        return post("/my/publishers", publisher.to_xml)
    end

    def create_filter(publisher, filter)
        logger.info("Creating #{filter.class} with name #{filter.name}")
        return post("#{publisher.uri}/#{filter.uri}", filter.to_xml)
    end

    def update_publisher(publisher)
        logger.info("Updating #{publisher.class} with name #{publisher.name}")
        return put("#{publisher.uri}/#{publisher.name}.xml", publisher.to_xml)
    end

    def update_filter(publisher, filter)
        logger.info("Creating #{filter.class} with name #{filter.name}")
        return put("#{publisher.uri}/#{filter.uri}/#{filter.name}.xml", filter.to_xml)
    end

    def remove_filter(publisher, filter)
        logger.info("Deleting #{filter.class} with name #{filter.name}")
        return delete("#{publisher.uri}/#{filter.uri}/#{filter.name}.xml")
    end
    alias_method :delete_filter, :remove_filter

    #### RULES

    # Gets a rule given an existing valid publisher/filter combination. 
	  # Used mostly for verification that the rule does exist.
    def get_rule(publisher, filter, rule)
      logger.info("Finding rule matching (#{rule.type}:#{rule.value}) on #{filter.class} for publisher #{publisher.name}")
      return get("#{publisher.uri}/filters/#{filter.name}/rules.xml?type=#{CGI.escape(rule.type)}&value=#{CGI.escape(rule.value)}")
    end
    
    # Verifies a rule exists given an existing valid publisher/filter combination. Used
    def rule_exists?(publisher, filter, rule)
      true if get_rule(publisher, filter, rule)
    end
    
    # Add a single rule to a filter, given valid publisher and filter.
    def add_rule(publisher, filter, rule)
        logger.info("Adding rule #{rule.value} to filter #{filter.name}")
        return post("#{publisher.uri}/filters/#{filter.name}/rules.xml", rule.to_xml)
    end
    
    # Add a Batch of Rules.
    def add_batch_rules(publisher, filter, ruleset=[])
      unless ruleset.is_a?(Array)
        add_rule(publisher, filter, ruleset)
      else
        logger.info("Bulk adding rules to filter named #{self.name} for publisher #{publisher.name}")
        return post("#{publisher.uri}/filters/#{filter.name}/rules.xml", rules_to_xml(ruleset))
      end
    end

    # Deletes a rule given an existing valid publisher/filter combination.
    def remove_rule(publisher, filter, rule)
        logger.info("Removing rule #{rule.value} from filter #{filter.name}")
        return delete("#{publisher.uri}/filters/#{filter.name}/rules?type=#{CGI.escape(rule.type)}&value=#{CGI.escape(rule.value)}") if rule
    end      
    alias_method :delete_rule, :remove_rule
    
    #### UTILITY METHODS
    
    def head(path)
        logger.debug('Doing HEAD')
        return http.get(path, headers)
    end

    def get(path)
        logger.debug('Doing GET')
        response = http.get2(path, headers)
        if (response.code == '200')
            if (response['Content-Encoding'] == 'gzip')
                logger.debug("Uncompressing the GET response")
                data = uncompress(response.body)
            else
                data = response.body
            end
        end
        logger.debug("GET result: #{data}")
        return [response, data]
    end

    def post(path, data)
        logger.debug("POSTing data: #{data}")
        return http.post2(path, compress(data), headers)
    end

    def put(path, data)
        logger.debug("PUTing data: #{data}")
        return http.put2(path, compress(data), headers)
    end

    def delete(path)
        logger.debug("Doing DELETE : #{path}")
        return http.delete(path, headers)
    end

    private

    def http
        hostname, port = @gnip_config.base_url.split(':')
        port ||= 443

        http = Net::HTTP.new(hostname, port)
        http.read_timeout=@gnip_config.http_read_timeout
        http.use_ssl = true if port == 443
        return http
    end

    def headers
        header_hash = {}
        header_hash['Authorization'] = 'Basic ' + Base64::encode64("#{@gnip_config.user}:#{@gnip_config.password}")
        header_hash['Content-Type'] = 'application/xml'
        header_hash['User-Agent'] = 'Gnip-Client-Ruby/2.0.6'
        if @gnip_config.use_gzip
            header_hash['Content-Encoding'] = 'gzip'
            header_hash['Accept-Encoding'] = 'gzip'
        end
        logger.debug("Gnip Connection Headers: #{header_hash}")
        header_hash
    end

    def compress(data)
        logger.debug("Gzipping data for request")
        if @gnip_config.use_gzip
            result = ''
            gzip_writer = Zlib::GzipWriter.new(StringIO.new(result))
            gzip_writer.write(data)
            gzip_writer.close
        else
            result = data
        end
        result
    end

    def uncompress(data)
        Zlib::GzipReader.new(StringIO.new(data)).read
    end

    def self.publishers_from_xml(publishers_xml)
        return [] if publishers_xml.nil?
        publishers_list = XmlSimple.xml_in(publishers_xml)
        return (publishers_list.empty? ? [] : publishers_list['publisher'].collect { |publisher_hash| Gnip::Publisher.from_hash(publisher_hash)})
    end
    
    def rules_to_xml(ruleset)
      return XmlSimple.xml_out(ruleset.collect { |rule| rule.to_hash }, {'AnonymousTag' => 'rule', 'RootName' => 'rules', 'XmlDeclaration' => Gnip.header_xml})
    end
end
