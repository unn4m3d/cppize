def lmethod(a,b,c,&block)
  block.call(a,b,c)
end

def cmethod
  lmethod do |a,b,c|
    "#{a+b}#{c}"
  end
end
