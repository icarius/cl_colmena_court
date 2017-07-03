class DailyMailReportWorker
	include Sidekiq::Worker
	def perform
		CaseController.new.daily_mail_report_fc
	end
end
