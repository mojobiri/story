require 'sinatra'
require 'csv'
require 'date'
require 'active_support/core_ext/object'

get '/' do
	@bug, @not_bug, @table, @users, headers = [], [], [], [], []
	arr_of_arrs = CSV.read("dess.csv")
	headers = arr_of_arrs[0]
	arr_of_arrs.delete_at(0)
	arr_of_arrs.each do |row|
		row = headers.zip(row).flatten
		@table << Hash[*row]
	end
	@table.each do |hash|
		hash['Created at'] = DateTime.parse(hash.fetch('Created at'))
	end
	@table.each { |hash| @users << hash.fetch('Owned By')}
	@users.uniq!.sort!.unshift("")
	@table = @table.sort_by { |k| k['Created at'] }.reverse
	@table.each do |hash|
		if hash.fetch('Current State') == 'accepted' || hash.fetch('Current State') == 'finished' || hash.fetch('Current State') == 'delivered'
			# Could use just .to_s == ""
				if !params[:owned_by].blank? && params[:created_at].blank?
					# Since params validates, we can remove strips
					if hash.fetch('Owned By') == params[:owned_by].lstrip.rstrip
						@bug << hash if hash.fetch('Story Type') == 'bug'
						@not_bug << hash if !(hash.fetch('Story Type') == 'bug')
					end
				elsif params[:owned_by].blank? && !params[:created_at].blank?
					if hash.fetch('Created at') == DateTime.parse(params[:created_at])
						@bug << hash if hash.fetch('Story Type') == 'bug'
						@not_bug << hash if !(hash.fetch('Story Type') == 'bug')
					end
				elsif !params[:owned_by].blank? && !params[:created_at].blank?
					if hash.fetch('Created at') == DateTime.parse(params[:created_at]) && hash.fetch('Owned By') == params[:owned_by].lstrip.rstrip
						@bug << hash if hash.fetch('Story Type') == 'bug'
						@not_bug << hash if !(hash.fetch('Story Type') == 'bug')
					end
				else
					@bug << hash if hash.fetch('Story Type') == 'bug'
					@not_bug << hash if !(hash.fetch('Story Type') == 'bug')
				end
		end
	end
	erb :index
end

 # row => {"first"=>"Oct 7, 2012", "third"=>"Oct 20, 2012", "second"=>"Oct 8, 2012"}

# DateTime.parse(row['first']) == DateTime.parse("2012.10.07") => true