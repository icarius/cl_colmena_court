class Case < ApplicationRecord

	has_many :case_histories
	has_many :case_notifications
	has_many :case_litigants
	has_many :case_solves
	has_many :case_exhorts

	def self.poderjudicial_crawler
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
		document = Nokogiri::HTML(self.send_request_court(cookie[:value], 'COLMENA'))
		if document.present?
			# Obtengo la tabla.
			row = document.css('.textoPortal')
			# Itero el resultado.
			row.each do |obj|
				begin
					data = {
						entry_number: obj.css('td')[0].text.squish,
						entry_date: obj.css('td')[1].text.squish,
						location: obj.css('td')[2].text.squish,
						location_date: obj.css('td')[3].text.squish,
						court: obj.css('td')[4].text.squish,
						caption: obj.css('td')[5].text.squish,
						public_detail_url: obj.css('td')[0].css('a')[0]['href']
					}
					puts data.inspect
					result << data
				rescue StandardError => e
					error_obj << obj
					puts "Parse error #{e.message}"
				end
			end
		end
		# Cierro el driver que le dio persistencia a la session durante la ejecucion.
		driver.quit
	end

	def self.send_request_court(jsessionid, search)
		require 'net/http'
		# http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoDAction.do (POST )
		begin
			uri_post = URI('http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoDAction.do')
			# Create client
			puts jsessionid
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
