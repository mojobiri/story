require 'sinatra'
require 'csv'
require 'date'
require 'active_support/core_ext/object'

get '/' do
	bug, not_bug, table, @users, @bug_v, @not_bug_v = [], [], [], [], [], []
	table = CSV.read("dess.csv", {:headers => true})
	table.each { |hash| hash['Created at'] = DateTime.parse(hash['Created at']) }
	table.each { |hash| @users << hash['Owned By'] }
	@users.uniq!.sort!
	table = table.select { |k| k['Current State'] =~ /(accepted|finished|delivered)/ }
	table = table.sort_by { |k| k['Created at'] }.reverse
	bug = table.select { |k| k['Story Type'] == 'bug' }
	not_bug = table.select { |k| !(k['Story Type'] == 'bug') }
				if !params[:owned_by].blank? && params[:created_at].blank?
					@bug_v = bug.select { |k| k['Owned By'] == params[:owned_by] }
					@not_bug_v = not_bug.select { |k| k['Owned By'] == params[:owned_by] }
				elsif params[:owned_by].blank? && !params[:created_at].blank?
					@bug_v = bug.select { |k| k['Created at'] == DateTime.parse(params[:created_at]) }
					@not_bug_v = not_bug.select { |k| k['Created at'] == DateTime.parse(params[:created_at]) }
				elsif !params[:owned_by].blank? && !params[:created_at].blank?
					@bug_v = bug.select { |k| k['Owned By'] == params[:owned_by] }.select { |k| k['Created at'] == DateTime.parse(params[:created_at]) }
					@not_bug_v = not_bug.select { |k| k['Owned By'] == params[:owned_by] }.select { |k| k['Created at'] == DateTime.parse(params[:created_at]) }
				else
					@bug_v = bug
					@not_bug_v = not_bug
				end
	erb :index
end