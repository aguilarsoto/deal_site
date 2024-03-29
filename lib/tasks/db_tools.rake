namespace :db_tools do
  desc "load a nonstandard (ugly) file from the publishers to the db"
  task :load_publishers_data_nonstandard => :environment do
    file_name = ask "Where is the File you want to load: "
    raise "File missing" unless File.file? file_name
    file = File.new(file_name, "r")
    header = ask ("does your file has a header?[y/n]: ")
    publisher= get_publisher
    header_line = split_line(file.gets.chomp) if header
    match_hash = set_row_matching(header, header_line)
    while (line = file.gets)
      line.chomp!
      if line =~ /^(.+?)\s+(\d+\/\d+\/\d+)\s+(\d+\/\d+\/\d+)?\s+(.+?)\s+(\d+)\s+(\d+).*$/
        line_hash = match_hash.clone
        line_hash.each do |key, value|
          line_hash[key] = $~[value]
        end
        advertiser = create_advertiser(publisher, line_hash)
        create_deals(advertiser, line_hash)
      end 
    end
  end
  
  desc "load_publishers_data, loads a standard csv or tsv file from the publishers into our db"
  task :load_publishers_data_standard  => :environment do
    file_name = ask "Where is the File you want to load: "
    raise "File missing" unless File.file? file_name
    file = File.new(file_name, "r")
    format = menu("tell us the file format: ", {'tsv' => "Tab separated values", 'csv' => "comma separated values"})
    header = ask ("does your file has a header?[y/n]: ")
    publisher= get_publisher
    header_line = split_line(file.gets.chomp, format) if header
    match_hash = set_row_matching(header, header_linei, true)
    while (line = file.gets)
      line.chomp!
      line_hash = match_hash.clone
      line = split_line(line, format)
      line_hash.each do |key, value|
        line_hash[key] = line[value]
      end
      advertiser = create_advertiser(publisher, line_hash)
      create_deals(advertiser, line_hash)
    end
  end

  def ask message
    begin 
      print message
      response = STDIN.gets.chomp
    end until !response.empty?
    response
  end

  def menu message, options
    selected = nil
    options.each do |key, option|
      puts "#{key}. #{option}"
    end
    begin
      selected = ask message
    end while ! options[selected]
    selected
  end

  def split_line line, format=nil
    if format == 'tsv'
      line.split(/\t/)
    elsif format == 'csv' 
      line.split(/,/)
    else
      line.split(/\s+/)
    end
  end

  def create_advertiser publisher, line_hash
    publisher.advertisers.find_or_create_by_name(line_hash[:name])
  end

  def create_deals advertise, line_hash
    advertise.deals.create(:value => line_hash[:value],
      :price => line_hash[:price],
      :description => line_hash[:description],
      :start_at => line_hash[:start_at],
      :end_at => line_hash[:end_at])
  end

  def set_row_matching header, header_line, standard=false
    puts "As a guide here is your header line positions"
    match_hash = {:name => "Advertisers's Name: ",
                  :value => "Deal's Value",
                  :price => "Deal's Price",
                  :description => "Deal's Description",
                  :start_at => "Deal's Start Date",
                  :end_at => "Deal's End Date"}
    header_line.each_with_index do |option, position|
      puts "#{standard ? position : position+1}. #{option}"
    end
    match_hash.each do |key, value|
      match_hash[key] = ask("What line corresponds to #{value}: ").to_i
    end
    match_hash
  end

  def get_publisher
    if ask("do you want to create a new publisher[y/n]: ").downcase == 'y'
      publisher_name = ask "what is the publishers name: "
      Publisher.create(:name => publisher_name)
    else
      publisher_id = menu("then pick an existing publisher: ", Hash[Publisher.all.map{|p| [p.id.to_s, p.name]}])
      Publisher.find(publisher_id)
    end
  end

end
