# puts "Event manager initialized"

unless File.exist? ('event_attendees.csv')
  puts "File does not exist"
  exit
end

# content = File.read('event_attendees.csv')
# puts content

# # this is one way to display the 3rd column of a csv(here is first name)
# This is not good since we want our pgm to be readable
# line = File.readlines('event_attendees.csv') # o/p is a array with each element a line in the csv
# line.each do|l|
#    puts l.split(',')[2]
# end

# # This is the other way
# lines = File.readlines('event_attendees.csv')
# lines.each do |line|
#   columns = line.split(",")
#   name = columns[2]
#   puts name
# end

# What if we want to not display the header line, we can do that by ommiting the 0th row
# lines = File.readlines('event_attendees.csv')
# lines.each_with_index do |line,index|
#     next if index == 0
#   columns = line.split(",")
#   name = columns[2]
#   puts name
# end

# All the above work is tedious and may run into errors if we have to deal with other csv files

# Therefore we will use ruby parser
# https://docs.ruby-lang.org/en/3.2/CSV.html

# we need to load in the csv module
require 'csv'

# content = CSV.open('event_attendees.csv', headers: true) # headers: true tells if the csv has headers or not
# content.each do |i| # it accesses each column
#   print i
# end

# The CSV library provides an additional option which allows us to convert the header names to symbols.
# Converting the headers to symbols will make our column names more uniform and easier to remember. The header “first_Name” will be converted to :first_name and “HomePhone” will be converted to :homephone.

# content = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol) # header_converter: converts the header to symbol
# content.each do |i| # it accesses each column based on the  symbol provided
#   name = i[:first_name]
#   zip_code = i[:zipcode]
#   puts "#{name} is in the location with zip code #{zip_code}"
# end

# in the above we can see that some of the zip are missing, some are 5 digits and some are lesser than 5 digits

# shorter zip codes are from states in the north-eastern part of the United States. Many zip codes there start with 0. This data was likely stored in the database as an integer, and not as text, which caused the leading zeros to be removed.

# For the people who did not provide a zip code, we use a default, bad zip code of “00000”.

# content = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
# content.each do |i| 
#   name = i[:first_name]
#   zip_code = i[:zipcode]

#   # If the zip is below 5 digits, append 0 till its fine (.rjust)
#   # If zip is above 5 digits,  truncate it to first 5 digits
#   # If zip is 5 leave it as it is
#   if zip_code.nil?
#     zip_code = "00000"
#   elsif(zip_code.length < 5 )
#     zip_code = zip_code.rjust(5,'0')
#   elsif (zip_code.length > 5)
#     zip_code = zip_code[0..4]
#   end
#   puts "#{name} - #{zip_code}"
# end

# In the above code, the cleaning of zip oversaturates the method.
# Therefore seperate it to another method

# def process_zip(zip_code)
#   # If the zip is below 5 digits, append 0 till its fine (.rjust)
#   # If zip is above 5 digits,  truncate it to first 5 digits
#   # If zip is 5 leave it as it is
#   if zip_code.nil?
#     return "00000"
#   elsif(zip_code.length < 5 )
#     return zip_code.rjust(5,'0')
#   elsif (zip_code.length > 5)
#     return zip_code[0..4]
#   end
#   zip_code
# end

# content = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
# content.each do |i| 
#   name = i[:first_name]
#   zip_code = i[:zipcode]

#   zip_code = process_zip(zip_code)

#   puts "#{name} - #{zip_code}"
# end

# In ruby, we want to have succint code, ie one line of code that can handle all the cases as we see below
# The .to_s makes nil object to ""
# The .rjust does not affect the string if it is above 5 digits
# The [0..4] does not affect strings that are 5 digits

# Therefore we can combine all ther above methods into one function
=begin
def process_zip(zip_code)
  zip_code.to_s.rjust(5,'0').slice(0..4) # This one line does all the functionality of the above if else statements
end

content = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
content.each do |i| 
  name = i[:first_name]
  zip_code = i[:zipcode]

  zip_code = process_zip(zip_code)

  puts "#{name} - #{zip_code}"
end
=end

# Using Google’s Civic Information
# Gives representative of the gov

# https://www.googleapis.com/civicinfo/v2/representatives?address=80203&levels=country&roles=legislatorUpperBody&roles=legislatorLowerBody&key=AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw

# https://www.theodinproject.com/lessons/ruby-event-manager#iteration-1-parsing-with-csv

# We can use this api to get info about the representative
# The result is in the form of json
# install the gem for google api client(done)

# we need to perform the following steps:

# Set the API Key
# Send the query with the given criteria
# Parse the response for the names of your legislators.
# Exploration of data is easy using irb

=begin
$ require 'google/apis/civicinfo_v2'
=> true

$ civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
=> #<Google::Apis::CivicinfoV2::CivicInfoService:0x007faf2dd47108 ... >

$ civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
=> "AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw"

$ response = civic_info.representative_info_by_address(address: 80202, levels: 'country', roles: ['legislatorUpperBody', 'legislatorLowerBody'])
=> #<Google::Apis::CivicinfoV2::RepresentativeInfoResponse:0x007faf2d9088d0 @divisions={"ocd-division/country:us/state:co"=>#<Google::Apis::CivicinfoV2::GeographicDivision:0x007faf2e55ea80 @name="Colorado", @office_indices=[0]> } > ...continues...
=end

=begin
require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = legislators.officials

    legislator_names = legislators.map(&:name)

    legislators_string = legislator_names.join(", ")
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end

  puts "#{name} #{zipcode} #{legislators_string}"
end
=end
# In the above code the legislator thingy can be moved to a seperate mehtod

=begin
require 'csv'
require 'google/apis/civicinfo_v2'


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = legislators.officials
    legislator_names = legislators.map(&:name)
    legislator_names.join(", ")
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  puts "#{name} #{zipcode} #{legislators}"
end
=end

# we now will send the letter

=begin
require 'csv'
require 'google/apis/civicinfo_v2'


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  
  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
      )
      legislators = legislators.officials
      legislator_names = legislators.map(&:name)
      legislator_names.join(", ")
    rescue
      'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
  end
  
  # puts 'EventManager initialized.'
  
contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
template_letter = File.read('form_letter.html')

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  personal_letter = template_letter.gsub('FIRST_NAME', name)
  personal_letter.gsub!('LEGISLATORS', legislators) # This has an issue that  it will replace the word "LEGISLATORS" all of them
  # We can make it better by using erb(template language)

  puts personal_letter
end
=end

# RB provides an easy to use but powerful templating system for Ruby. Using ERB, actual Ruby code can be added to any plain text document for the purposes of generating document information details and/or flow control.

=begin
require 'erb'

meaning_of_life = 42

question = "The Answer to the Ultimate Question of Life, the Universe, and Everything is <%= meaning_of_life %>"
template = ERB.new question

results = template.result(binding)
puts results
=end

# We first make a new erb template using erb.new with the question string
# This question string contains erb template for loading in the value of the meaning of life

# We send the binding method, ie that it returns a binding object that knows the state of all the variables in scope
# Therefore with the help of binding the variable is able to access the value of meaning of life

# <% %> are used for embedding ruby code into html and do not give an output
# <%= %> are used for embedding ruby code into html and give an output

# We are using the ERB tag that does not output the results <% %> to check if the legislators variable is an Array.
# If it is an array, we output the name and website url of each legislator.
# If legislators is not an array, it means that the legislators_by_zipcode method entered the rescue clause, which outputs a string. We want to display that string.

=begin
require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end

end
=end
# We want to seperate it into a different method

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)
end
