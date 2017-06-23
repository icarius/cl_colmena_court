class DetailWorker
	include Sidekiq::Worker
	def perform(data)
		require 'open-uri'
		require 'nokogiri'
		# puts "Link*"
		# puts data.inspect
		# puts data[:link_caso_detalle]
		document = Nokogiri::HTML(Case.get_case_detail(data["link_caso_detalle"]))
		if document.present?
			# Obtengo los elementos del dom y los asocio a objetos segun tema.
			recurso = document.css('#recurso tr.textoBarra .textoPortal tr')
			expediente = document.css('#expediente tr.textoBarra .textoPortal tr')
			historia = document.css('#divHistoria > table:nth-child(2) tr')
			litigantes = document.css('#divLitigantes > table:nth-child(2) tr')
			# Recorro los objetos para obtener datos.
			# Obtengo datos faltantes de recurso.
			recurso.each do |detail|
				detail.css('td').each do |obj|
					if obj.text.squish.strip.include? "Estado Recurso:"
						data[:estado_recurso] = obj.text.squish.strip.gsub('Estado Recurso:', '').squish.downcase
					end
					if obj.text.squish.strip.include? "Estado Procesal:"
						data[:estado_procesal] = obj.text.squish.strip.gsub('Estado Procesal:', '').squish.downcase
					end
					if obj.text.squish.strip.include? "Recurso :"
						data[:recurso] = obj.text.squish.strip.gsub('Recurso :', '').squish.downcase
					end
				end
			end
			# Obtengo datos faltantes de expediente.
			expediente.each do |detail|
				detail.css('td').each do |obj|
					if obj.text.squish.strip.include? "RUC :"
						data[:ruc] = obj.text.squish.strip.gsub('RUC :', '').squish.downcase
					end
					if obj.text.squish.strip.include? "Rol o Rit :"
						data[:rol_rit] = obj.text.squish.strip.gsub('Rol o Rit :', '').squish.downcase
					end
				end
			end
			# El objeto caso se encuentra completo por lo que lo creo en la BD.
			caso = Case.where(tipo_causa: data[:tipo_causa], correlativo: data[:correlativo], ano: data[:ano], corte: data[:corte]).first || self.create(data)
			# TODO Agregar el ID del caso a un array que posteriormente se utilizara para enviar el reporte de novedades sobre nuevas causas.
			# Obtengo datos faltantes de litigantes.
			litigantes.each do |row|
				litigante = { case_id: caso[:id] }
				row.css('td').each_with_index do |obj, index|
					case index
					when 0
						litigante[:sujeto] = obj.text.squish.strip
					when 1
						litigante[:rut] = obj.text.squish.strip.downcase
					when 2
						litigante[:persona] = obj.text.squish.strip.downcase
					when 3
						litigante[:razon_social] = obj.text.squish.strip
					end
				end
				# Creo el objeto litigante solo si no existe.
				CaseLitigant.where(case_id: litigante[:case_id], rut: litigante[:rut]).first || CaseLitigant.create(litigante)
			end
			# Obtengo datos faltantes de expediente.
			historia.each do |row|
				registro = { case_id: caso[:id] }
				row.css('td').each_with_index do |obj, index|
					case index
					when 0
						registro[:folio] = obj.text.squish.strip
					when 1
						registro[:ano] = obj.text.squish.strip
					when 2
						if  obj.css('img')[0]['onclick'].include? "ShowPDF"
							registro[:link_doc] = 'http://corte.poderjudicial.cl' + obj.css('img')[0]['onclick'].gsub("ShowPDF('", '').gsub("')", '')
						end
						if obj.css('img')[0]['onclick'].include? "ShowWord"
							registro[:link_doc] = 'http://corte.poderjudicial.cl' + obj.css('img')[0]['onclick'].gsub("ShowWord('", '').gsub("')", '')
						end
					when 3
						# Nada por que al parecer nunca va nada.
						# Sino se parece al anterior.
					when 4
						registro[:sala] = obj.text.squish.strip
					when 5
						registro[:tramite] = obj.text.squish.strip
					when 6
						registro[:descripcion_tramite] = obj.text.squish.strip
					when 7
						registro[:fecha_tramite] = obj.text.squish.strip
					when 8
						registro[:estado] = obj.text.squish.strip
					end
				end
				# Creo el objeto historia solo si no existe.
				CaseHistory.where(case_id: registro[:case_id], folio: registro[:folio]).first || CaseHistory.create(registro)
			end
		end
	end
end
