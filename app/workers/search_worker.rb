class SearchWorker
	include Sidekiq::Worker
	def perform
		require 'selenium-webdriver'
		require 'nokogiri'
		require 'sidekiq/api'
		# Inicializo objetos que contendran los resultados.
		search = "COLMENA"
		result = Array.new
		error_obj = Array.new		
		driver = Case.get_driver
		# Obtengo el valor de JSESSIONID.
		cookie = driver.manage.cookie_named("JSESSIONID")
		puts cookie.inspect
		# Ejecuto el request y obtengo el dom.
		document = Nokogiri::HTML(Case.send_request_court(cookie[:value], search))
		if document.present?
			# Obtengo la tabla.
			row = document.css('.textoPortal')
			# Itero el resultado.
			row[8..-1].each do |obj|
				begin
					ningreso_arr = obj.css('td')[0].text.squish.split('-')
					# Filtro para reducir la muestra de causas obtenidas desde la consulta contra el servidor.
					if ningreso_arr[ningreso_arr.length-1].squish.to_i >= 2014
						data = {
							ningreso: obj.css('td')[0].text.squish,
							tipo_causa: ningreso_arr[((ningreso_arr.length)*-1)..ningreso_arr.length-3].join(' '),
							correlativo: ningreso_arr[ningreso_arr.length-2].squish,
							ano: ningreso_arr[ningreso_arr.length-1].squish,
							corte: obj.css('td')[4].text.squish,
							fecha_ingreso: obj.css('td')[1].text.squish,
							ubicacion: obj.css('td')[2].text.squish,
							fecha_ubicacion: obj.css('td')[3].text.squish,
							caratulado: obj.css('td')[5].text.squish,
							link_caso_detalle: 'http://corte.poderjudicial.cl' + obj.css('td')[0].css('a')[0]['href']
						}
						# Verifico que no exista la causa.
						if !Case.exists?(tipo_causa: data[:tipo_causa], correlativo: data[:correlativo], ano: data[:ano], corte: data[:corte])
							# Por cada elemento obtengo su detalle.
							DetailWorker.perform_async(data)
						end
					end
				rescue StandardError => e
					error_obj << obj
					puts "Parse error #{e.message}"
				end
			end
		end
		# Cierro el driver que le dio persistencia a la session durante la ejecucion.
		driver.close
		SearchWorker.perform_at(1.day.from_now)
	end
end
