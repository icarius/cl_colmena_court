class DailyMailReportWorker
	include Sidekiq::Worker
	def perform
		now_date_time = DateTime.now
		destinatarios = [
			{
				:name => 'Felipe I. González G.',
				:email => 'felipe@coddea.com'
			}
		]
		# Mail 1
		title1 = 'Nuevas causas '+now_date_time.strftime('%d-%m-%Y')
		@cases = Case.poderjudicial_new_cases
		msj1_txt = ""
		msj1_html = render_to_string partial: '/shared/mail/news', :locals => {:@title => title1}, :object => @cases, layout: false
		Case.send_email(
			title1,
			destinatarios,
			msj1_txt,
			msj1_html
		)
		# Mail 2
		title2 = 'Novedades '+now_date_time.strftime('%d-%m-%Y')
		@elements = Case.poderjudicial_news_cases_details
		msj2_html = render_to_string partial: '/shared/mail/developments', :locals => {:@title => title2}, :object => @elements, layout: false
		Case.send_email(
			title2,
			destinatarios,
			msj1_txt,
			msj2_html
		)
		# render :json => { :status => true }, :status => 200
	end
end
