class CrawlerController < ApplicationController

	def welcome
		render :json => { :status => true, :message => "No se encontraron noticias2." }, :status => 200
	end

	def poder_judicial_civil
		require 'typhoeus'
		require 'nokogiri'
		result = Array.new
		if params[:search].nil?
			search = "Colmena"
		else
			search = params[:search]
		end
		request = Typhoeus::Request.new(
			"http://civil.poderjudicial.cl/CIVILPORWEB/AtPublicoDAction.do",
			method: :post,
			headers: {
				"Pragma" => "no-cache",
				"Origin" => "http://civil.poderjudicial.cl",
				"Accept-Encoding" => "gzip, deflate",
				"Accept-Language" => "es,en;q=0.8",
				"Upgrade-Insecure-Requests" => 1,
				"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36",
				"Content-Type" => "application/x-www-form-urlencoded",
				"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
				"Cache-Control" => "no-cache",
				"Referer" => "http://civil.poderjudicial.cl/CIVILPORWEB/AtPublicoViewAccion.do?tipoMenuATP=1",
				"Cookie" => "FLG_Version=0; FLG_Turno=0; CRR_IdFuncionario=1; COD_TipoCargo=2; COD_Tribunal=0; COD_Corte=98; COD_Usuario=autoconsulta1; GLS_Tribunal=Tribunal de Prueba 1; GLS_Comuna=Santiago; COD_Ambiente=3; COD_Aplicacion=2; GLS_Usuario=Juan Pena Perez; HORA_LOGIN=01:15; _ga=GA1.2.1541246786.1468964940; JSESSIONID=0001XuvmIzA2omGy2oPK33kn8pg+zwasportal11",
				"Connection" => "keep-alive",
				"Host" => "civil.poderjudicial.cl",
				"Content-Length" => 239
			},
			body: "TIP_Consulta=4&TIP_Lengueta=tdCuatro&TIP_Causa=C&ROL_Causa=&ERA_Causa=&FEC_Desde=24%2F07%2F2016&FEC_Hasta=24%2F07%2F2016&RUT_Consulta=&RUT_DvConsulta=&NOM_Consulta="+search+"&APE_Paterno=&APE_Materno=&COD_Tribunal=0&irAccionAtPublico=Consulta"
		)
		request.run
		body = Nokogiri::HTML(request.response.body)
		row = body.css('#contentCellsAddTabla tr')
		row.each do |obj|
			data = {
				rol: obj.css('td')[0].text.squish,
				fecha: obj.css('td')[1].text.squish,
				caratulado: obj.css('td')[2].text.squish,
				tribunal: obj.css('td')[3].text.squish
			}
			result = Array.new << data
		end
		if result.any?
			render :json => { :status => true, :message => "Se encontraron las siguientes causas.", :result => result }, :status => 200
		else
			render :json => { :status => false, :message => "No se encontraron causas.", :result => result }, :status => 200
		end
	end

end
