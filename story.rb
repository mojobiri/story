require 'sinatra'
require 'csv'
require 'date'
require 'active_support/core_ext/object'

get '/' do
	bug, not_bug, table, @users, headers, table_selected, @bug_v, @not_bug_v = [], [], [], [], [], [], [], []
	arr_of_arrs = CSV.read("dess.csv")
	headers = arr_of_arrs[0]
	arr_of_arrs.delete_at(0)
	arr_of_arrs.each do |row|
		row = headers.zip(row).flatten
		table << Hash[*row]
	end
	table.each do |hash|
		hash['Created at'] = DateTime.parse(hash.fetch('Created at'))
	end
	table.each { |hash| @users << hash.fetch('Owned By')}
	@users.uniq!.sort!.unshift("")
	table_selected = table.select { |k| k['Current State'] =~ /(accepted|finished|delivered)/ }
	table_selected = table_selected.sort_by { |k| k['Created at'] }.reverse
	bug = table_selected.select { |k| k['Story Type'] == 'bug' }
	not_bug = table_selected.select { |k| !(k['Story Type'] == 'bug') }
				if !params[:owned_by].blank? && params[:created_at].blank?
					@bug_v = bug.select { |k| k['Owned By'] == params[:owned_by] }
					@not_bug_v = not_bug.select { |k| k['Owned By'] == params[:owned_by] }
				elsif params[:owned_by].blank? && !params[:created_at].blank?
					@bug_v = bug.select { |k| k['Created at'] == DateTime.parse(params[:created_at]) }
					@not_bug_v = not_bug.select { |k| k['Created at'] == DateTime.parse(params[:created_at]) }
				elsif !params[:owned_by].blank? && !params[:created_at].blank?
					not_bug_tmp, bug_tmp = [], []
					bug_tmp = bug.select { |k| k['Created at'] == DateTime.parse(params[:created_at]) }
					@bug_v = bug_tmp.select { |k| k['Owned By'] == params[:owned_by] }
					not_bug_tmp = not_bug.select { |k| k['Created at'] == DateTime.parse(params[:created_at]) }
					@not_bug_v = not_bug_tmp.select { |k| k['Owned By'] == params[:owned_by] }
				else
					@bug_v = bug
					@not_bug_v = not_bug
				end
	erb :index
end