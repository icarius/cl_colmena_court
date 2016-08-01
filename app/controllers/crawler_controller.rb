class CrawlerController < ApplicationController

	def poder_judicial_corte
		require 'patron'
		require 'nokogiri'
		result = Array.new
		error_obj = Array.new
		# 	uri_base = URI('http://corte.poderjudicial.cl/SITCORTEPORWEB/')
		# 	uri = URI('http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoDAction.do')
		# 	# Create client
		# 	http = Net::HTTP.new(uri.host, uri.port)
		# 	response_base = http.get(uri_base)
		# 	all_cookies = response_base.get_fields('set-cookie')
		# 	cookies_array = Array.new
		# 	all_cookies.each { | cookie |
		# 		cookies_array.push(cookie.split('; ')[0])
		# 	}
		# 	cookies = cookies_array.join('; ')
		sess = Patron::Session.new
		sess.base_url = "http://corte.poderjudicial.cl"
		sess.connect_timeout = 1000000
		sess.timeout = 60
		sess.handle_cookies(file = nil)
		sess.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36'
		step1 = sess.get("/SITCORTEPORWEB/")
		step1_cookie = step1.headers['Set-Cookie'][0].split(';')[0].gsub('JSESSIONID=', '')
		document = Nokogiri::HTML(send_request_court("00002DDiTWHQLQSDuo564uf-xeb:-1"))
		if document.present?
			row = document.css('.textoPortal')
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
					# Creamos un registro en la BD.
					caso = Case.new(data)
					caso.save
					result << data
				rescue StandardError => e
					error_obj << obj
					puts "Parse error #{e.message}"
				end
			end
			if result.present?
				render :json => { :status => true, :message => "Se encontraron las siguientes causas.", :result => result }, :status => 200
			else
				render :json => { :status => false, :message => "No se encontraron causas.", :result => result }, :status => 200
			end
		else
			render :json => { :status => false, :message => "No respondio nada.", :result => result }, :status => 200
		end
	end

	def send_request_civil(jsessionid)
		require 'net/http'
		begin
			uri = URI('http://civil.poderjudicial.cl/CIVILPORWEB/AtPublicoDAction.do')
			# Create client
			http = Net::HTTP.new(uri.host, uri.port)
			data = {
				"NOM_Consulta" => 'COLMENA',
				"TIP_Lengueta" => "tdCuatro",
				"TIP_Causa" => "C",
				"ERA_Causa" => "",
				"ROL_Causa" => "",
				"FEC_Desde" => "24/07/2016",
				"TIP_Consulta" => "4",
				"FEC_Hasta" => "24/07/2016",
				"RUT_Consulta" => "",
				"APE_Paterno" => "",
				"COD_Tribunal" => "0",
				"RUT_DvConsulta" => "",
				"APE_Materno" => "",
				"irAccionAtPublico" => "Consulta",
			}
			body = URI.encode_www_form(data)
			# Create Request
			req =  Net::HTTP::Post.new(uri)
			# Add headers
			req.add_field "Connection", "keep-alive"
			# Add headers
			req.add_field "Accept-Encoding", "gzip, deflate"
			# Add headers
			req.add_field "Upgrade-Insecure-Requests", "1"
			# Add headers
			req.add_field "Content-Type", "application/x-www-form-urlencoded"
			# Add headers
			req.add_field "Origin", "http://civil.poderjudicial.cl"
			# Add headers
			req.add_field "Cache-Control", "no-cache"
			# Add headers
			req.add_field "User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36"
			# Add headers
			req.add_field "Cookie", "FLG_Version=0; FLG_Turno=0; CRR_IdFuncionario=1; COD_TipoCargo=2; COD_Tribunal=0; COD_Corte=98; COD_Usuario=autoconsulta1; GLS_Tribunal=Tribunal de Prueba 1; GLS_Comuna=Santiago; COD_Ambiente=3; COD_Aplicacion=2; GLS_Usuario=Juan Peña Perez; HORA_LOGIN=08:46; _ga=GA1.2.1541246786.1468964940; JSESSIONID=#{jsessionid}"
			# Add headers
			req.add_field "Referer", "http://civil.poderjudicial.cl/CIVILPORWEB/AtPublicoViewAccion.do?tipoMenuATP=1"
			# Add headers
			req.add_field "Pragma", "no-cache"
			# Add headers
			req.add_field "Accept-Language", "es,en;q=0.8"
			# Add headers
			req.add_field "Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
			# Set header and body
			req.body = body
			# Fetch Request
			res = http.request(req)
			puts "Response HTTP Status Code: #{res.code}"
			#puts "Response HTTP Response Body: #{res.body}"
			return res.body
		rescue StandardError => e
			puts "HTTP Request failed (#{e.message})"
			return false
		end
	end

	def send_request_court(jsessionid)
		require 'net/http'
		begin
			uri = URI('http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoDAction.do')
			# Create client
			http = Net::HTTP.new(uri.host, uri.port)
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
				"FEC_Desde" => "31/07/2016",
				"NOM_Consulta" => "COLMENA",
				"irAccionAtPublico" => "Consulta",
				"COD_Libro" => "null",
				"APE_Materno" => "",
				"ROL_Recurso" => "",
				"ROL_Causa" => "",
				"FEC_Hasta" => "31/07/2016",
				"RUC_Dv" => "",
				"selConsulta" => "0",
				"ERA_Causa" => "",
				"RUC_Era" => "",
			}
			body = URI.encode_www_form(data)
			# Create Request
			req =  Net::HTTP::Post.new(uri)
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
			req.add_field "User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36"
			# Add headers
			req.add_field "Cookie", "CRR_IdFuncionario=0; COD_TipoCargo=0; COD_Corte=90; COD_Usuario=autoconsulta; GLS_Corte=C.A. de Santiago; COD_Ambiente=3; COD_Aplicacion=3; GLS_Usuario=; HORA_LOGIN=10:14; NUM_SalaUsuario=0; JSESSIONID=#{jsessionid}; _ga=GA1.2.1541246786.1468964940; _gat=1"
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
			return res.body
			# puts "Response HTTP Response Body: #{res.body}"
		rescue StandardError => e
			puts "HTTP Request failed (#{e.message})"
			return nil
		end
	end

end
