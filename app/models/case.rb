class Case < ApplicationRecord

	def self.search(term, current_page)
		if term
			page(current_page).where('caption LIKE ?', "%#{term}%").order('id DESC')
		else
			page(current_page).order('id DESC') 
		end
	end

end
