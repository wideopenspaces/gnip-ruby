class Gnip::Activity

  attr_reader :actors, :at, :url, :action, :tos, :regardingURLs, :destinationURLs, :sources, :tags, :keywords, :places, :payload

  def initialize(actors, action, at = Time.now, url = nil, tos = [], regardingURLs = [], sources = [], tags = [], payload = nil, destinationURLs = [], keywords = [], places = [])
    @actors = actors
    @action = action
    if (at.class == Time)
      @at = at.xmlschema
    else
      @at = at unless Time.xmlschema(at).nil?
    end
    @url = url
    @tos = tos
    @regardingURLs = regardingURLs
    @sources = sources
    @tags = tags
    @payload = payload
    @destinationURLs = destinationURLs
    @keywords = keywords
    @places = places
  end
  
  def actor 
    unless @actors.empty?
     @actors.first.is_a?(Hash) ? @actors.first["content"] : @actors.first
    end
  end
  
  def to(idx)
    @tos[idx].is_a?(Hash) ? @tos[idx]["content"] : @tos[idx]
  end

  def to_xml()
    the_hash = self.to_hash
    XmlSimple.xml_out(the_hash, {'RootName' => ''})
  end

  def to_hash()
    result = {}
    result['at'] = [@at]
    result['action'] = [@action]
    result['actor'] = @actors if @actors
    result['url'] = [@url] if @url
    result['to'] = @tos if @tos
    result['regardingURL'] = @regardingURLs if @regardingURLs
    result['source'] = @sources if @sources
    result['tag'] = @tags if @tags
    result['payload'] = @payload.to_hash if @payload
    result['destinationURL'] = @destinationURLs if @destinationURLs
    result['keyword'] = @keywords if @keywords
    result['place'] = @places if @places

    {'activity' => result }
  end

  def ==(another)
    another.instance_of?(self.class) && another.at == at && another.url == url && another.action == action && another.actor == actor
  end

  alias eql? ==

  def self.from_hash(hash)
    return if hash.nil? || hash.empty?    
    payload = Gnip::Payload.from_hash(hash['payload'].first) if hash['payload']
    Gnip::Activity.new(hash['actor'], first(hash['action']), first(hash['at']),
             first(hash['url']), hash['to'], hash['regardingURL'], hash['source'], hash['tag'], payload,
             hash['destinationURL'], hash['keyword'], hash['place'])
  end

  def self.from_xml(document)
    hash = XmlSimple.xml_in(document)
    self.from_hash(hash)
  end

  def self.list_to_xml(activity_list)
    activity_list = [] if activity_list.nil?
    return XmlSimple.xml_out(activity_list.collect { |activity| activity.to_hash}, {'RootName' => 'activities', 'AnonymousTag' => nil, 'XmlDeclaration' => Gnip.header_xml})
  end

  def self.list_from_xml(activities_xml)
    return [] if activities_xml.nil?
    activities_list = XmlSimple.xml_in(activities_xml)
    publisher_name = activities_list['publisher']
    publisher = Gnip::Publisher.new(publisher_name) if publisher_name
    activities = (activities_list.empty? ? [] : activities_list['activity'].collect { |activity_hash| Gnip::Activity.from_hash(activity_hash)})
    if (publisher.nil?)
      return activities
    else
      return publisher, activities
    end
  end

  class Gnip::Activity::Builder

    def initialize(action, at = Time.now)
      @action = action
      @at = at
      @actors = []
      @places = []
      @tags = []
      @keywords = []
      @destinationURLs = []
      @regardingURLs = []
      @sources = []
      @tos = []
    end

    def actor(actor, uid=nil, metaURL=nil)
      actor = { "content" => actor }
      actor.merge!("uid" => uid) if uid
      actor.merge!("metaURL" => metaURL) if metaURL
      @actors.push(actor)      
      self
    end
    
    def actors(actors = [])
      @actors = actors
      self
    end

    def activityID(activityID)
      @activityID = activityID
      self
    end
    
    def url(url)
      @url = url
      self
    end
    
    def place(point=nil, elev=nil, floor=nil, type_tag=nil, name=nil, relationship_tag=nil)
      place = {}
      place.merge!("point" => [point])  if point
      place.merge!("elev" => [elev])    if elev
      place.merge!("floor" => [floor])  if floor
      place.merge!("featuretypetag" => [type_tag])  if type_tag
      place.merge!("featurename" => [name])         if name
      place.merge!("relationshiptag" => [relationship_tag]) if relationship_tag
      @places.push(place)
      self
    end
    
    def places(places = [])
      @places = places
      self
    end

    def keywords(keywords = [])
      @keywords = keywords
      self
    end

    def keyword(keyword)
      @keywords.push(keyword)
      self
    end

    def tos(tos = [])
      @tos = tos
      self
    end

    def to(to, metaURL=nil)
      to = {"content" => to}
      to.merge!("metaURL" => metaURL) if metaURL
      @tos.push(to)
      self
    end

    def tags(tags = [])
      @tags = tags
      self
    end

    def tag(tag)
      @tags.push(tag)
      self
    end
    
    def destinationURL(destinationURL, metaURL=nil)
      destinationURL = { "content" => destinationURL }
      destinationURL.merge!( "metaURL" => metaURL ) if metaURL
      @destinationURLs.push(destinationURL)
      self
    end
    
    def destinationURLs(destinationURLs = [])
      @destinationURLs = destinationURLs
      self
    end

    def regardingURL(regardingURL, metaURL=nil)
      regardingURL = { "content" => regardingURL }
      regardingURL.merge!( "metaURL" => metaURL ) if metaURL     
      @regardingURLs.push(regardingURL)
      self
    end
    
    def regardingURLs(regardingURLs = [])
      @regardingURLs = regardingURLs
      self
    end

    def sources(sources = [])
      @sources = sources
      self
    end
    
    def source(source)
      @sources.push(source)
      self
    end

    def payload(payload)
      @payload = payload
      self
    end

    def build
      Gnip::Activity.new(@actors, @action, @at, @url, @tos, @regardingURL, @sources, @tags, @payload, @destinationURLs, @keywords, @places)
    end

  end

  private

  def self.first(array)
    array[0] unless array.nil?
  end

end
