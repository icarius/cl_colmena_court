class SearchWorker
	include Sidekiq::Worker
	def perform
		require 'selenium-webdriver'
		require 'nokogiri'
		require 'sidekiq/api'
		# Inicializo objetos que contendran los resultados.
		search = "COLMENA"
		error_obj = Array.new		
		driver = Case.get_driver
		# Obtengo el valor de JSESSIONID.
		cookie = driver.manage.cookie_named("JSESSIONID")
		# Ejecuto el request y obtengo el dom.
		document = Nokogiri::HTML(Case.send_request_court(cookie[:value], search))
		if document.present?
			# Obtengo la tabla.
			row = document.css('.textoPortal')
			# Itero el resultado.
			row[8..-1].each do |obj|
				ObjectBuildWorker.perform_async(obj)
			end
		end
		# Cierro el driver que le dio persistencia a la session durante la ejecucion.
		driver.close
		SearchWorker.perform_at(1.day.from_now)
	end
end
