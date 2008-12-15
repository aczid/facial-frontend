=begin
YAML.add_ruby_type(/^class/) { |type, val|
  val =~ /\A[A-Z][A-Za-z0-9_]*(::[A-Z][A-Za-z0-9_]*)*\z/ or raise YAML::Error, "Invalid Class: #{val.inspect}"
  eval val
}
class Class
  def to_yaml(opts = {})
    YAML::quick_emit(nil, opts) { |out|
      out << "!ruby/class "
      self.name.to_yaml(:Emitter => out)
    }
  end

  def is_complex_yaml?
    false
  end
end
=end
