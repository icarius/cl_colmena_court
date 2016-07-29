class CrawlerController < ApplicationController

	def welcome
		render :json => { :status => true, :message => "No se encontraron noticias2." }, :status => 200
	end

	def poder_judicial_civil
		require 'typhoeus'
		require 'nokogiri'
		# result = Array.new
		# if params[:search].nil?
		# 	search = "colmena"
		# else
		# 	search = params[:search]
		# end

		###################################
		### Obtiene header & session id ###
		###################################
		# request1 = Typhoeus::Request.new(
		# 	"http://civil.poderjudicial.cl/CIVILPORWEB/",
		# 	method: :get
		# )
		# request1.run
		# headers = request1.response.headers.to_s
		# header_obj = JSON.parse headers.gsub('=>', ':')
		# session_id = header_obj['Set-Cookie'][0].split(';')[0].gsub('JSESSIONID=', '')
		# cookie = "FLG_Version=0; FLG_Turno=0; CRR_IdFuncionario=1; COD_TipoCargo=2; COD_Tribunal=0; COD_Corte=98; COD_Usuario=autoconsulta1; GLS_Tribunal=Tribunal de Prueba 1; GLS_Comuna=Santiago; COD_Ambiente=3; COD_Aplicacion=2; GLS_Usuario=Juan Pena Perez; HORA_LOGIN=08:46; _ga=GA1.2.1541246786.1468964940; "+header_obj['Set-Cookie'][0].split(';')[0]+"+zwasportal11"
		# cookie = "FLG_Version=0; FLG_Turno=0; CRR_IdFuncionario=1; COD_TipoCargo=2; COD_Tribunal=0; COD_Corte=98; COD_Usuario=autoconsulta1; GLS_Tribunal=Tribunal de Prueba 1; GLS_Comuna=Santiago; COD_Ambiente=3; COD_Aplicacion=2; GLS_Usuario=Juan Peña Perez; HORA_LOGIN=08:46; _ga=GA1.2.1541246786.1468964940; JSESSIONID=0003zft1cZ2IAVhVP0fJjhdI3RL+zwasportal12+zwasportal11"

		# "0001O-mN_As4AZoOOANEyagZXlX+zwasportal10"
		# "00014E7BK2DjPEzHFt-rABrHOiK+zwasportal10"

		# puts "- DEBUG -"
		# puts session_id
		# puts "---"
		# puts cookie
































		###############################
		### Consulta sobre buscador ###
		###############################
		# request2 = Typhoeus::Request.new(
		# 	"http://civil.poderjudicial.cl/CIVILPORWEB/AtPublicoDAction.do",
		# 	method: :post,
		# 	headers: {
		# 		"Pragma" => "no-cache",
		# 		"Origin" => "http://civil.poderjudicial.cl",
		# 		"Accept-Encoding" => "gzip, deflate",
		# 		"Accept-Language" => "es,en;q=0.8",
		# 		"Upgrade-Insecure-Requests" => 1,
		# 		"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36",
		# 		"Content-Type" => "application/x-www-form-urlencoded",
		# 		"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
		# 		"Cache-Control" => "no-cache",
		# 		"Referer" => "http://civil.poderjudicial.cl/CIVILPORWEB/AtPublicoViewAccion.do?tipoMenuATP=1",
		# 		"Cookie" => cookie,
		# 		"Connection" => "keep-alive",
		# 		"Host" => "civil.poderjudicial.cl",
		# 		"Content-Length" => 239
		# 	},
		# 	body: "TIP_Consulta=4&TIP_Lengueta=tdCuatro&TIP_Causa=C&ROL_Causa=&ERA_Causa=&FEC_Desde=24%2F07%2F2016&FEC_Hasta=24%2F07%2F2016&RUT_Consulta=&RUT_DvConsulta=&NOM_Consulta=COLMENA&APE_Paterno=&APE_Materno=&COD_Tribunal=0&irAccionAtPublico=Consulta"
		# )
		# request2.run
		# puts "- DEBUG -"
		# puts request2.response.body
		
		#body = Nokogiri::HTML(search_request_civil("COLMENA", "0003zft1cZ2IAVhVP0fJjhdI3RL+zwasportal12+zwasportal11"))
		body = Nokogiri::HTML(search_request_corte("COLMENA", "0000yBl_ImwapLSUjDnNwvZPZwL:-1"))
		if !body.empty?
			row = body.css('#contentCellsAddTabla tr')
			row.each do |obj|
				puts obj
				# data = {
				# 	rol: obj.css('td')[0].text.squish,
				# 	date: obj.css('td')[1].text.squish,
				# 	caption: obj.css('td')[2].text.squish,
				# 	court: obj.css('td')[3].text.squish
				# }
				# # Creamos un registro en la BD.
				# caso = Case.new(data)
				# caso.save
				# puts "- DEBUG Data -"
				# puts data
				# result << data
			end
			if result.empty?
				render :json => { :status => true, :message => "Se encontraron las siguientes causas.", :result => result }, :status => 200
			else
				render :json => { :status => false, :message => "No se encontraron causas.", :result => result }, :status => 200
			end
		else
			render :json => { :status => false, :message => "No respondio nada.", :result => result }, :status => 200
		end
	end

	def index
		@cases = Case.all
	end

	def search_request_corte(key, jsessionid)
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
				"FEC_Desde" => "28/07/2016",
				"NOM_Consulta" => key,
				"irAccionAtPublico" => "Consulta",
				"COD_Libro" => "null",
				"APE_Materno" => "",
				"ROL_Recurso" => "",
				"ROL_Causa" => "",
				"FEC_Hasta" => "28/07/2016",
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
			req.add_field "Cookie", "CRR_IdFuncionario=0; COD_TipoCargo=0; COD_Corte=90; COD_Usuario=autoconsulta; GLS_Corte=C.A. de Santiago; COD_Ambiente=3; COD_Aplicacion=3; GLS_Usuario=; HORA_LOGIN=12:30; NUM_SalaUsuario=0; JSESSIONID=#{jsessionid}; _ga=GA1.2.1541246786.1468964940; _gat=1;"
			# Add headers
			req.add_field "Referer", "http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoViewAccion.do?tipoMenuATP=1"
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

	def search_request_civil(key, jsessionid)
		require 'net/http'
		begin
			uri = URI('http://civil.poderjudicial.cl/CIVILPORWEB/AtPublicoDAction.do')
			# Create client
			http = Net::HTTP.new(uri.host, uri.port)
			data = {
				"NOM_Consulta" => key,
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

end
