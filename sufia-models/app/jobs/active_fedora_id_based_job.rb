class ActiveFedoraIdBasedJob
  def queue_name
    :id_based
  end

  attr_accessor :id

  def initialize(id)
    self.id = id
  end

  def object
    @object ||= ActiveFedora::Base.find(id)
  end

  alias_method :generic_file, :object
  alias_method :generic_file_id, :id

  def run
    raise "Define #run in a subclass"
  end
end
