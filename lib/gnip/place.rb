class Gnip::Place
  attr_accessor :point, :elev, :floor, :featuretypetag, :featurename, :relationshiptag
  
  def initialize(point=nil,  elev=nil,  floor=nil,  featuretypetag=nil,  featurename=nil,  relationshiptag=nil)
      @point, @elev, @floor = point, elev, floor
      @featuretypetag, @featurename, @relationshiptag = featuretypetag, featurename, relationshiptag
  end

  def to_xml()
      XmlSimple.xml_out(self.to_hash, {'RootName' => ''})
  end

  def to_hash()
      result = {}
      result['point'] = [@point] if @point
      result['elev'] = [@elev] if @elev
      result['floor'] = [@floor] if @floor
      result['featuretypetag'] = [@featuretypetag] if @featuretypetag
      result['featurename'] = [@featurename] if @featurename
      result['relationshiptag'] = [@relationshiptag] if @relationshiptag
      result
  end

  def self.from_hash(hash)
      return if hash.nil?  || hash.empty?
      point = hash['point'].first if hash['point']
      elev = hash['elev'].first if hash['elev']
      floor = hash['floor'].first if hash['floor']
      featuretypetag = hash['featuretypetag'].first if hash['featuretypetag']
      featurename = hash['featurename'].first if hash['featurename']
      relationshiptag = hash['relationshiptag'].first if hash['relationshiptag']

      new(point,  elev,  floor,  featuretypetag,  featurename,  relationshiptag)
  end

  def self.from_xml(document)
      hash = XmlSimple.xml_in(document)
      self.from_hash(hash)
  end
  
  def ==(another)
      another.instance_of?(self.class) && another.point == @point && another.elev == @elev && 
        another.floor == @floor && another.featuretypetag == @featuretypetag && 
        another.featurename == @featurename && another.relationshiptag == @relationshiptag 
  end
  alias eql? ==
end