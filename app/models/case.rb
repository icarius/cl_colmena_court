class Case < ApplicationRecord

	has_many :case_histories
	has_many :case_litigants

	def self.poderjudicial_crawler(search)
		require 'selenium-webdriver'
		require 'nokogiri'
		# Inicializo objetos que contendran los resultados.
		result = Array.new
		error_obj = Array.new
		# Creo el driver para obtener la session y poder ejecutar el request.
		driver = Selenium::WebDriver.for :phantomjs, args: '--proxy=66.175.216.65:8118'
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
						ubicacion: obj.css('td')[2].text.squish,
						fecha_ubicacion: obj.css('td')[3].text.squish,
						caratulado: obj.css('td')[5].text.squish,
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
		# document = Nokogiri::HTML(open(data[:link_caso_detalle], proxy: URI.parse("http://66.175.216.65:8118")))
		document = Nokogiri::HTML(self.get_case_detail(data[:link_caso_detalle]))
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
			caso = self.where(tipo_causa: data[:tipo_causa], correlativo: data[:correlativo], ano: data[:ano], corte: data[:corte]).first || self.create(data)
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
		return data
	end

	def self.send_request_court(jsessionid, search)
		require 'net/http'
		#http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoDAction.do (POST )
		begin
			uri_post = URI('http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoDAction.do')
			# Create client
			http = Net::HTTP.new(uri_post.host, uri_post.port, '66.175.216.65', 8118)
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
			puts "Search response HTTP Status Code: #{res.code}"
			if res.code.to_i == 200
				return res.body
			else
				if self.switch_tor_circuit
					return self.send_request_court(jsessionid, search)
				else
					return nil
				end
			end
		rescue StandardError => e
			puts "Search HTTP Request failed (#{e.message})"
			if self.switch_tor_circuit
				return self.send_request_court(jsessionid, search)
			else
				return nil
			end
		end
	end

	def self.get_case_detail(uri)
		require 'net/http'
		begin
			uri_get = URI(uri)
			http = Net::HTTP.new(uri_get.host, uri_get.port, '66.175.216.65', 8118)
			req =  Net::HTTP::Get.new(uri)
			res = http.request(req)
			puts "Detail response HTTP Status Code: #{res.code} URI: #{uri}"
			if res.code.to_i == 200
				return res.body
			else
				if self.switch_tor_circuit
					return self.get_case_detail(uri)
				else
					return nil
				end
			end
		rescue StandardError => e
			puts "Detail HTTP Request failed (#{e.message})"
			if self.switch_tor_circuit
				return self.get_case_detail(uri)
			else
				return nil
			end
		end
	end

	def self.switch_tor_circuit
		puts "Retry..."
		require 'net/telnet'
		localhost = Net::Telnet::new("Host" => "127.0.0.1", "Port" => "9051", "Timeout" => 10, "Prompt" => /250 OK\n/)
		localhost.cmd('AUTHENTICATE "colmena"') { |c| print c; throw "Cannot authenticate to Tor" if c != "AUTHENTICATE 250 OK\n" }
		localhost.cmd('signal NEWNYM') { |c| print c; throw "Cannot switch Tor to new route" if c != "signal NEWNYM 250 OK\n" }
		localhost.close
		sleep(2)
		return true
	end

	def self.send_request_court_mechanize(jsessionid, search)
		require 'mechanize'
		browser = Mechanize.new
		begin
			browser.post(
				'http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoDAction.do',
				[
					["TIP_Consulta","3"],
					["TIP_Lengueta","tdNombre"],
					["APE_Paterno",""],
					["TIP_Causa","+"],
					["RUC_Tribunal"=>""],
					["RUC_Numero"=>""],
					["COD_Corte"=>""],
					["COD_Corte"=>"0"],
					["ERA_Recurso"=>""],
					["COD_LibroCmb"=>""],
					["FEC_Desde"=>"15/08/2016"],
					["NOM_Consulta"=>"#{search}"],
					["irAccionAtPublico"=>"Consulta"],
					["COD_Libro"=>"null"],
					["APE_Materno"=>""],
					["ROL_Recurso"=>""],
					["ROL_Causa"=>""],
					["FEC_Hasta"=>"15/08/2016"],
					["RUC_Dv"=>""],
					["selConsulta"=>"0"],
					["ERA_Causa"=>""],
					["RUC_Era"=>""]
					],
					{
						'Content-Type' => 'application/x-www-form-urlencoded',
						'Connection' => 'keep-alive',
						'Accept-Encoding' => 'gzip, deflate',
						'Upgrade-Insecure-Requests' => '1',
						'Origin' => 'http://corte.poderjudicial.cl',
						'Cache-Control' => 'no-cache',
						'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36',
						'Cookie' => "CRR_IdFuncionario=0; COD_TipoCargo=0; COD_Corte=90; COD_Usuario=autoconsulta; GLS_Corte=C.A. de Santiago; COD_Ambiente=3; COD_Aplicacion=3; GLS_Usuario=; HORA_LOGIN=12:05; NUM_SalaUsuario=0; JSESSIONID=#{jsessionid}; _ga=GA1.2.1541246786.1468964940; _gat=1",
						'Referer' => 'http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoViewAccion.do?tipoMenuATP=1',
						'Pragma' => 'no-cache',
						'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
						'Accept-Language' => 'es,en;q=0.8'
					}
					) do |page|
				return page.body
			end
		rescue StandardError => e
			puts "HTTP Request failed (#{e.message})"
			return nil
		end
	end

	def self.test_driver_proxy
		require 'selenium-webdriver'
		# Creo el driver para obtener la session y poder ejecutar el request.
		driver = Selenium::WebDriver.for :phantomjs, args: '--proxy=66.175.216.65:8118'
		driver.navigate.to "http://corte.poderjudicial.cl/SITCORTEPORWEB/"
		# Obtengo el valor de JSESSIONID.
		cookie = driver.manage.cookie_named("JSESSIONID")
		return cookie[:value]
	end

end
