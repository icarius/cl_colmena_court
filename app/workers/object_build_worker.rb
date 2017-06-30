class ObjectBuildWorker
	include Sidekiq::Worker
	def perform(html)
		obj = Nokogiri::HTML(html)
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
			# Filtro de cantidad por año
			if ningreso_arr[ningreso_arr.length-1].squish.to_i > 2015 
				# Verifico que no exista la causa.
				if !Case.exists?(tipo_causa: data[:tipo_causa], correlativo: data[:correlativo], ano: data[:ano], corte: data[:corte])
					# Por cada elemento obtengo su detalle.
					DetailWorker.perform_async(data)
				end
			end
		end
	end
end
