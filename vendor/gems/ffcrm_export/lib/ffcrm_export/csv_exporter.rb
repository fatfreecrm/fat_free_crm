module FfcrmExport
  class CsvExporter
    def self.dump(date=nil)
      date ||= Date.today
      csv_string = CSV.generate do |csv|
        csv << ["Identifier","Leads","Opportunities","Prospecting Meetings", "Calls", "Submitted RFPs", "Generated Revenue"]
        User.all.each do |user|
          lead_count = user.leads.where{ (created_at >= my{date.beginning_of_day}) & (created_at <= my{date.end_of_day}) }.count
          opportunity_count = user.opportunities.where{ (created_at >= my{date.beginning_of_day}) & (created_at <= my{date.end_of_day}) }.count
          prospecting_meeting_count = Task.where{ (completed_by == my{user.id}) & (category == 'meeting') & (completed_at >= my{date.beginning_of_day}) & (completed_at <= my{date.end_of_day}) }.count
          call_count = user.leads.where{ (updated_at >= my{date.beginning_of_day}) & (updated_at <= my{date.end_of_day}) & (status == 'contacted') }.count
          rfp_count = user.opportunities.tagged_with("RFP").where{ (updated_at >= my{date.beginning_of_day}) & (updated_at <= my{date.end_of_day}) & (stage == 'proposal') }.count
          rev_closed = user.opportunities.where{ (updated_at >= my{date.beginning_of_day}) & (updated_at <= my{date.end_of_day}) & (stage == 'closed') }.sum('amount')
          
          csv << [user.email,lead_count,opportunity_count,prospecting_meeting_count,call_count,rfp_count,rev_closed]
        end
      end
    end
  end
end