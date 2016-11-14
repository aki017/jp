
def show_version
  puts "v#{Jp::VERSION}"
end

def parse_pointer(q)
  q.sub(%r{\A/}, '').split("/").map{|f|
    f.gsub(/~1/, '/').gsub(/~0/, '~')
  }
end

def dump(key, obj, query, format)
  query ||=[]
  show_all = query.size == 0

  # │
  if format == :f1
    if key.size > 1
      print "/"
      print key[0..-2].join("/")
    end

    if key.size > 0
      print "/"
      print key[-1]
    end
  elsif format == :f2
    print "$"
    if key.size > 1
      print key[0..-2].map{|k| "["+JSON.dump(k)+"]"}.join
    end

    if key.size > 0
      print "["
      print JSON.dump(key[-1])
      print "]"
    end
  end
  print ": "
  case obj
  when Integer, Float
    puts obj
  when String
    puts JSON.dump(obj).set_color(:green)
  when nil
    puts "null".set_color(:light_black)
  else
    puts obj.class.to_s.set_color(:light_blue)
  end

  case obj
  when Hash
    obj.each do |k, v|
      show = show_all || query.first == k
      if show
        dump([*key, k], v, query[1..-1], format)
      end
    end
  when Array
    obj.each_with_index do |v, i|
      show = false
      show ||= show_all
      show ||= (query.first.to_i == i && query.first.to_i.to_s == query.first)
      show ||= (obj.size + query.first.to_i == i && query.first.to_i.to_s == query.first)
      show ||= (query.first == "~")
      if show
        dump([*key, i], v, query[1..-1], format)
      end
    end
  end
end

def __main__(argv)
  opt = OptionParser.new

  version = false
  format = :f1
  opt.on("-v", "--version") {|v| version = v}
  opt.on("-f1") {|v| format = :f1}
  opt.on("-f2") {|v| format = :f2}
  opt.parse!(ARGV)

  if version
    show_version
    exit
  end

  query = ARGV[1] || ""

  if ARGV[2].nil?
    data = JSON.parse($stdin.read)
  else
    data = JSON.parse(File.read(ARGV[2]))
  end
  dump([], data, parse_pointer(query), format)
end
