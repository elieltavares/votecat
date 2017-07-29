require 'radiator'
require 'yaml'

require_relative 'include/parse.rb'
patch_file = 'config.yml'
## Debug
unless File.exist?(patch_file)
	puts ("File #{patch_file} don't exist")
end
## Config
@power = 100
@config = YAML.load_file(patch_file)
@only_tags = parse_list(@config[:only_tags])
## Start the program
while true
	api = Radiator::DatabaseApi.new
	response = api.get_discussions_by_created("tag": @only_tags[0],"limit": 1)
	@author = response.result[0].author
	@permlink = response.result[0].permlink
    	@config[:voters].each do |voter|
		account, wif = voter.split(' ')
		vp = api.get_accounts([account])
		@voting_power = vp.result[0].voting_power/100.0
		tx = Radiator::Transaction.new(wif: wif)
	next if response.result[0].active_votes.map(&:voter).include? account
		vote = {
			type: :vote,
			voter: account,
			author: @author,
			permlink: @permlink,
			weight: 10000
		}
		if @voting_power <= @power
			tx.operations << vote
			puts tx.process(true)
			puts "Você já votou para @#{@author}/#{@permlink}"
		end
		puts @voting_power
	end
	puts @voting_power
	#sleep 7200
end
