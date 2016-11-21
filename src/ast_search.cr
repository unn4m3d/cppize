abstract class Crystal::ASTNode

  def children
    if self.responds_to?(:expressions)
      self.expressions
    elsif self.responds_to?(:body)
      if self.body.nil?
        nil
      else
        self.body.as(ASTNode).children || self.body
      end
    else
      nil
    end
  end

  def search_of_type(node_type : Class, recur : Bool = false)
    array = [children].flatten.select { |x| x.class == node_type }

    if recur
      array.each { |elem| array += elem.search_of_type(node_type, recur) unless elem.nil? }
    end
    array.select { |x| !x.nil? }
  end
end
