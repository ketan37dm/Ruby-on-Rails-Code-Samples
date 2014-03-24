module Admins::QuotesHelper
	def get_quote_by_date(date)
		date = DateTime.new(date.year, date.month, date.day)
		@quote = Quote.find_by_date(date) || current_admin.quotes.build
	end

	def get_quote_url(quote,count)
		quote.id.nil? ? admins_quotes_path(:count => count) : admins_quote_path(:id => quote.id, :count => count)
	end
end
