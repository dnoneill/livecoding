require 'net/http'
require 'csv'
require 'json'
uri = URI('https://data.un.org/ws/rest/data/DF_UNData_UNFCC')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true if uri.scheme == 'https'
req = Net::HTTP::Get.new uri
req['Accept'] = "text/csv"

res = http.start { |http| http.request req }

reqstructure = Net::HTTP::Get.new uri
reqstructure['Accept'] = "text/json"

resstructure = http.start { |http| http.request reqstructure }
# req = Net::HTTP::Get.new(uri)
# req['Accept'] = "file/json"

# res = Net::HTTP.start(uri.hostname, uri.port,:use_ssl => uri.scheme == 'https') {|http|
#     http.request(req)
# }

structure = JSON.parse(resstructure.body)
structuredict = {}
structure['structure']['dimensions']['series'].each do |struct|
    struct['values'].each do |value|
        structuredict[value['id']] = value['name']
    end
end


csvlist = CSV.parse(res.body, :col_sep => ',', :headers => true).map(&:to_h)
#print(csvlist)
code = 'EN_ATM_METH_XLULUCF'
methaneonly = []
puts 'testing'
csvlist.each do |row|
    if row['INDICATOR'] == code
        newrow = {}
        row.each do |key, value|
            newrowvalue =  structuredict.keys.include?(row[key]) ? structuredict[row[key]] : row[key]
            newrow[key] = newrowvalue
        end
        methaneonly.append(newrow)
    end
end
column_names = methaneonly.first.keys
s=CSV.generate do |csv|
    csv << column_names
    methaneonly.each do |x|
      csv << x.values
    end
end
File.write("#{code}-ruby.csv", s)