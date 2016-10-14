class StudyCase < ApplicationRecord

	def self.study_crawler(search)
		require 'selenium-webdriver'
		require 'nokogiri'
		# Inicializo objetos que contendran los resultados.
		result = Array.new
		error_obj = Array.new
		# Creo el driver para obtener la session y poder ejecutar el request.
		driver = Selenium::WebDriver.for :phantomjs
		driver.navigate.to "http://corte.poderjudicial.cl/SITCORTEPORWEB/"
		# Obtengo el valor de JSESSIONID.
		cookie = driver.manage.cookie_named("JSESSIONID")
		# Ejecuto el request y obtengo el dom.
		document = Nokogiri::HTML(self.send_request_court(cookie[:value], search))
		if document.present?
			# Obtengo la tabla.
			row = document.css('.textoPortal')
			# Itero el resultado.
			row[8..-1].each do |obj|
				begin
					ningreso_arr = obj.css('td')[0].text.squish.split('-')
					data = {
						ningreso: obj.css('td')[0].text.squish,
						tipo_causa: ningreso_arr[((ningreso_arr.length)*-1)..ningreso_arr.length-3].join(' '),
						correlativo: ningreso_arr[ningreso_arr.length-2].squish,
						ano: ningreso_arr[ningreso_arr.length-1].squish,
						corte: obj.css('td')[4].text.squish,
						fecha_ingreso: obj.css('td')[1].text.squish,
						link_caso_detalle: 'http://corte.poderjudicial.cl' + obj.css('td')[0].css('a')[0]['href']
					}
					# Verifico que no exista la causa.
					if !self.exists?(tipo_causa: data[:tipo_causa], correlativo: data[:correlativo], ano: data[:ano], corte: data[:corte])
						# Por cada elemento obtengo su detalle.
						result << self.detalle_recurso_scraper(data)
					end
				rescue StandardError => e
					error_obj << obj
					puts "Parse error #{e.message}"
				end
			end
		end
		# Cierro el driver que le dio persistencia a la session durante la ejecucion.
		driver.quit
		# Determino la respuesta.
		if result.any?
			return result
		else
			return false
		end
	end

	def self.detalle_recurso_scraper(data)
		require 'open-uri'
		require 'nokogiri'
		document = Nokogiri::HTML(open(data[:link_caso_detalle]))
		if document.present?
			# Obtengo los elementos del dom y los asocio a objetos segun tema.
			recurso = document.css('#recurso tr.textoBarra .textoPortal tr')
			expediente = document.css('#expediente tr.textoBarra .textoPortal tr')
			litigantes = document.css('#divLitigantes > table:nth-child(2) tr')
			# Recorro los objetos para obtener datos.
			# Obtengo datos faltantes de recurso.
			recurso.each do |detail|
				detail.css('td').each do |obj|
					if obj.text.squish.strip.include? "Estado Procesal:"
						data[:estado_procesal] = obj.text.squish.strip.gsub('Estado Procesal:', '').squish.downcase
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
						rol_rit_arr = obj.text.squish.strip.gsub('Rol o Rit :', '').squish.downcase.split('-')
						data[:rol] = rol_rit_arr[rol_rit_arr.length-2].squish.downcase
						data[:rit] = rol_rit_arr[rol_rit_arr.length-1].squish.downcase
					end
				end
			end
			# Obtengo datos faltantes de litigantes.
			cont_ab_recurrente = 1
			cont_recurrente = 1
			litigantes.each do |row|
				litigante = {}
				row.css('td').each_with_index do |obj, index|
					case index
					when 0
						litigante[:sujeto] = obj.text.squish.strip
					when 1
						case litigante[:sujeto]
						when 'Ab. Recurrente'
							case cont_ab_recurrente
							when 1
								data[:abrecurrente_rut_1] = obj.text.squish.strip.downcase
							when 2
								data[:abrecurrente_rut_2] = obj.text.squish.strip.downcase
							when 3
								data[:abrecurrente_rut_3] = obj.text.squish.strip.downcase
							when 4
								data[:abrecurrente_rut_4] = obj.text.squish.strip.downcase
							end
						when 'Recurrente'
							case cont_recurrente
							when 1
								data[:recurrente_rut_1] = obj.text.squish.strip.downcase
							when 2
								data[:recurrente_rut_2] = obj.text.squish.strip.downcase
							when 3
								data[:recurrente_rut_3] = obj.text.squish.strip.downcase
							when 4
								data[:recurrente_rut_4] = obj.text.squish.strip.downcase
							end
						when 'Recurrido'
							data[:recurrido_rut] = obj.text.squish.strip.downcase
						end
					when 3
						case litigante[:sujeto]
						when 'Ab. Recurrente'
							case cont_ab_recurrente
							when 1
								data[:abrecurrente_nombre_1] = obj.text.squish.strip
							when 2
								data[:abrecurrente_nombre_2] = obj.text.squish.strip
							when 3
								data[:abrecurrente_nombre_3] = obj.text.squish.strip
							when 4
								data[:abrecurrente_nombre_4] = obj.text.squish.strip
							end
							cont_ab_recurrente = cont_ab_recurrente + 1
						when 'Recurrente'
							case cont_recurrente
							when 1
								data[:recurrente_nombre_1] = obj.text.squish.strip
							when 2
								data[:recurrente_nombre_2] = obj.text.squish.strip
							when 3
								data[:recurrente_nombre_3] = obj.text.squish.strip
							when 4
								data[:recurrente_nombre_4] = obj.text.squish.strip
							end
							cont_recurrente = cont_recurrente + 1
						when 'Recurrido'
							data[:recurrido_nombre] = obj.text.squish.strip
						end
					end
				end
			end
		end
		self.create(data)
		return data
	end

	def self.send_request_court(jsessionid, search)
		require 'net/http'
		# http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoDAction.do (POST )
		begin
			uri_post = URI('http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoDAction.do')
			# Create client
			http = Net::HTTP.new(uri_post.host, uri_post.port)
			data = {
				"TIP_Consulta" => "3",
				"TIP_Lengueta" => "tdNombre",
				"APE_Paterno" => "",
				"TIP_Causa" => "+",
				"RUC_Tribunal" => "",
				"RUC_Numero" => "",
				"COD_Corte" => "0",
				"ERA_Recurso" => "",
				"COD_LibroCmb" => "",
				"FEC_Desde" => "15/08/2016",
				"NOM_Consulta" => "#{search}",
				"irAccionAtPublico" => "Consulta",
				"COD_Libro" => "null",
				"APE_Materno" => "",
				"ROL_Recurso" => "",
				"ROL_Causa" => "",
				"FEC_Hasta" => "15/08/2016",
				"RUC_Dv" => "",
				"selConsulta" => "0",
				"ERA_Causa" => "",
				"RUC_Era" => "",
			}
			body = URI.encode_www_form(data)
			# Create Request
			req =  Net::HTTP::Post.new(uri_post)
			# Add headers
			req.add_field "Connection", "keep-alive"
			# Add headers
			req.add_field "Accept-Encoding", "gzip, deflate"
			# Add headers
			req.add_field "Upgrade-Insecure-Requests", "1"
			# Add headers
			req.add_field "Content-Type", "application/x-www-form-urlencoded"
			# Add headers
			req.add_field "Origin", "http://corte.poderjudicial.cl"
			# Add headers
			req.add_field "Cache-Control", "no-cache"
			# Add headers
			req.add_field "User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36"
			# Add headers
			req.add_field "Cookie", "CRR_IdFuncionario=0; COD_TipoCargo=0; COD_Corte=90; COD_Usuario=autoconsulta; GLS_Corte=C.A. de Santiago; COD_Ambiente=3; COD_Aplicacion=3; GLS_Usuario=; HORA_LOGIN=12:05; NUM_SalaUsuario=0; JSESSIONID=#{jsessionid}; _ga=GA1.2.1541246786.1468964940; _gat=1"
			# Add headers
			req.add_field "Referer", "http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoViewAccion.do?tipoMenuATP=1"
			# Add headers
			req.add_field "Pragma", "no-cache"
			# Add headers
			req.add_field "Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
			# Add headers
			req.add_field "Accept-Language", "es,en;q=0.8"
			# Set header and body
			req.body = body
			# Fetch Request
			res = http.request(req)
			puts "Response HTTP Status Code: #{res.code}"
			#puts "Response HTTP Response Body: #{res.body}"
			return res.body
		rescue StandardError => e
			puts "HTTP Request failed (#{e.message})"
			return nil
		end
	end

end
