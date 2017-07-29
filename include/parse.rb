def parse_list(list)
  if !!list && File.exist?(list)
    f = File.open(list)
    elements = []
    
    f.each_line do |line|
      elements += line.split(' ')
    end
    
    elements.uniq.reject(&:empty?).reject(&:nil?)
  else
    list.to_s.split(' ')
  end
end
