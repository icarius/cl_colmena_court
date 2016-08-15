class Case < ApplicationRecord

	has_many :case_histories
	has_many :case_notifications
	has_many :case_litigants
	has_many :case_solves
	has_many :case_exhorts

	def self.poderjudicial_crawler(search)
		require 'nokogiri'
		# Declaro los array que almacenaran el resultado.
		result = Array.new
		a = Mechanize.new { |agent|
			agent.user_agent_alias = 'Mac Safari'
		}
		site = Array.new
		page = a.get('http://corte.poderjudicial.cl/SITCORTEPORWEB/')
		site << page
		page.frames.each do |frame|
			site << a.get(frame.href)
		end
		puts "kaosbite"
		puts site[3].inspect
		puts site[3].forms
	end

	def self.poder_judicial_corte
		require 'patron'
		require 'nokogiri'
		result = Array.new
		error_obj = Array.new

		# Estrategia 1
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

		# Estrategia 2
		# sess = Patron::Session.new
		# sess.base_url = "http://corte.poderjudicial.cl"
		# sess.connect_timeout = 1000000
		# sess.timeout = 60
		# sess.handle_cookies(file = nil)
		# sess.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36'
		# step1 = sess.get("/SITCORTEPORWEB/")
		# step1_cookie = step1.headers['Set-Cookie'][0].split(';')[0].gsub('JSESSIONID=', '')
		# puts step1_cookie

		# Estrategia 3
		# uri = URI('http://corte.poderjudicial.cl/SITCORTEPORWEB/')
		# http = Net::HTTP.new(uri.host, uri.port)
		# response_base = http.get(uri)
		# jsessionid = response_base.get_fields('set-cookie')[0].split(';')[0].gsub('JSESSIONID=', '')

		# Estrategia 4
		# document = nil
		# uri = URI('http://corte.poderjudicial.cl/SITCORTEPORWEB/')
		# Net::HTTP.start(uri.host, uri.port) do |http|
		# 	request = Net::HTTP::Get.new uri.request_uri
		# 	response = http.request request
		# 	jsessionid = response.get_fields('set-cookie')[0].split(';')[0].gsub('JSESSIONID=', '')
		# 	puts jsessionid
		# 	document = Nokogiri::HTML(self.send_request_court(jsessionid, 'COLMENA'))
		# end

		# Estrategia 5
		# require 'net/http/persistent'
		# uri = URI('http://corte.poderjudicial.cl/SITCORTEPORWEB/')
		# http = Net::HTTP::Persistent.new 'poder_judicial'
		# # perform a GET
		# response = http.request uri
		# jsessionid = response.get_fields('set-cookie')[0].split(';')[0].gsub('JSESSIONID=', '')
		# puts jsessionid
		# document = Nokogiri::HTML(self.send_request_court('0000RtfyYAPRNHd4cUiMQSnfExh:-1', 'COLMENA'))

		# Estrategia 6
		# require 'httpclient'
		# client1 = HTTPClient.new
		# puts "kaosbite 1"
		# client1.get_content('http://corte.poderjudicial.cl/SITCORTEPORWEB/')
		# puts client1.cookies
		# client2 = HTTPClient.new
		# puts "kaosbite 2"
		# client2.get_content('http://corte.poderjudicial.cl/SITCORTEPORWEB/jsp/General/COR_GRL_HeadAutoconsulta.jsp')
		# puts client2.cookies
		# client3 = HTTPClient.new
		# puts "kaosbite 3"
		# client3.get_content('http://corte.poderjudicial.cl/SITCORTEPORWEB/jsp/Menu/Comun/COR_MNU_BlancoAutoconsulta.jsp')
		# puts client3.cookies
		# client4 = HTTPClient.new
		# puts "kaosbite 4"
		# client4.get_content('http://corte.poderjudicial.cl/SITCORTEPORWEB/jsp/General/COR_GRL_Body.jsp')
		# puts client4.cookies
		# client5 = HTTPClient.new
		# client5.get_content('http://corte.poderjudicial.cl/SITCORTEPORWEB/InicioAplicacion.do')
		# puts client5.cookies
		# client6 = HTTPClient.new
		# client6.get_content('http://corte.poderjudicial.cl/SITCORTEPORWEB/jsp/Login/LoginAutoconsulta.jsp')
		# puts client6.cookies
		# document = Nokogiri::HTML(self.send_request_court(client6.cookies, 'COLMENA'))

		# uri_post = URI('http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoDAction.do')
		# data = {
		# 	"TIP_Consulta" => "3",
		# 	"TIP_Lengueta" => "tdNombre",
		# 	"APE_Paterno" => "",
		# 	"TIP_Causa" => "+",
		# 	"RUC_Tribunal" => "",
		# 	"RUC_Numero" => "",
		# 	"COD_Corte" => "0",
		# 	"ERA_Recurso" => "",
		# 	"COD_LibroCmb" => "",
		# 	"FEC_Desde" => "15/08/2016",
		# 	"NOM_Consulta" => "COLMENA",
		# 	"irAccionAtPublico" => "Consulta",
		# 	"COD_Libro" => "null",
		# 	"APE_Materno" => "",
		# 	"ROL_Recurso" => "",
		# 	"ROL_Causa" => "",
		# 	"FEC_Hasta" => "15/08/2016",
		# 	"RUC_Dv" => "",
		# 	"selConsulta" => "0",
		# 	"ERA_Causa" => "",
		# 	"RUC_Era" => "",
		# }
		# body = URI.encode_www_form(data)
		# header = {
		# 	"Connection" => "keep-alive",
		# 	"Accept-Encoding" => "gzip, deflate",
		# 	"Upgrade-Insecure-Requests" => "1",
		# 	"Content-Type" => "application/x-www-form-urlencoded",
		# 	"Origin" => "http://corte.poderjudicial.cl",
		# 	"Cache-Control" => "no-cache",
		# 	"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36",
		# 	"Referer" => "http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoViewAccion.do?tipoMenuATP=1",
		# 	"Pragma" => "no-cache",
		# 	"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
		# 	"Accept-Language" => "es,en;q=0.8"
		# }
		# res = client.post_content(uri_post, body, header)
		# puts "kaosbite"
		# puts res.inspect
		
		# Estrategia 8
		# require 'watir-webdriver'
		# browser = Watir::Browser.new
		# browser.goto 'http://corte.poderjudicial.cl/SITCORTEPORWEB/'
		# browser.text_field(:name => 'NOM_Consulta').set 'COLMENA'
		# browser.link(:href => 'javascript:AtPublicoPpalForm.irAccionAtPublico.click()').click

		# Estrategia 7
		require "selenium-webdriver"
		driver = Selenium::WebDriver.for :firefox
		driver.navigate.to "http://corte.poderjudicial.cl/SITCORTEPORWEB/"
		cookie = driver.manage.cookie_named("JSESSIONID")
		puts cookie[:value]
		document = Nokogiri::HTML(self.send_request_court(cookie[:value], 'COLMENA'))
		if document.present?
			row = document.css('.textoPortal')
			row.each do |obj|
				begin
					puts "entre entre"
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
					# Creamos un registro en la BD.
					result << data
				rescue StandardError => e
					error_obj << obj
					puts "Parse error #{e.message}"
				end
			end
		end
		driver.quit
	end

	def self.send_request_court(jsessionid, search)
		require 'net/http'
		# http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoDAction.do (POST )
		begin
			uri_post = URI('http://corte.poderjudicial.cl/SITCORTEPORWEB/AtPublicoDAction.do')
			# Create client
			# JSESSIONID=0000MpKmLoFEfVoyTq7f50ntq79:-1
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
