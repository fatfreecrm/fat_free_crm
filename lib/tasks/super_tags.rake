# Fat Free CRM
# Copyright (C) 2008-2011 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

namespace :super_tags do

  desc "Migrate super_tags plugin to core custom_fields"
  task :migrate => :environment do
    def dryrun?
      #~ true
      ENV['DRYRUN'] == 'true'
    end

    columns = %w(tag_id field_name field_type field_label table_name select_options max_size required disabled form_field_type field_info)
    map_as = {
      'short_answer' => 'string',
      'number'       => 'decimal',
      'long_answer'  => 'text',
      'select_list'  => 'select',
      'multi_select' => 'check_boxes',
      'checkbox'     => 'boolean',
      'date'         => 'date',
      'datetime'     => 'datetime'
    }
    group_ids = {}
    updates = []

    connection = ActiveRecord::Base.connection

    field_data = connection.select_all "SELECT #{columns.join(', ')} FROM customfields"

    tag_ids = field_data.map {|row| row['tag_id']}.uniq
    tag_ids.each do |tag_id|
      tag = ActsAsTaggableOn::Tag.find(tag_id)

      if (data = connection.select_all "SELECT * FROM tag#{tag_id}s").present?
        keys = data.first.keys.reject {|k| %w(id customizable_id customizable_type).include?(k)}

        # FieldGroup
        unless field_group = FieldGroup.find_by_tag_id(tag.id)
          group_params = {:tag_id => tag.id, :name => tag.name + ' Details'}
          if dryrun?
            puts group_params
          else
            field_group = FieldGroup.create! group_params
          end
        end

        klass_names = data.map {|row| row['customizable_type']}.uniq
        klass_names.each do |klass_name|
          klass = klass_name.constantize

          # CustomField
          field_data.each do |row|
            next unless row['tag_id'] == tag_id

            unless field = CustomField.find_by_klass_name_and_name(klass_name, row['field_name'])

              collection = row['select_options'].split('|').map(&:strip) if row['select_options']

              field_params = {
                :klass_name => klass_name,
                :name       => row['field_name'],
                :label      => row['field_label'],
                :position   => row['position'],
                :collection => collection,
                :as         => map_as[row['form_field_type']],
                :hint       => row['field_info'],
                :required   => row['required'],
                :disabled   => row['disabled'],
                :maxlength  => row['max_size'],
                :field_group_id => field_group.try(:id)
              }
              if dryrun?
                puts field_params
              else
                field = CustomField.create! field_params
              end
            end
          end

          # Data
          data.each do |row|
            values = []
            keys.each do |key|
              next unless klass.column_names.include?(key)

              value = if row[key] =~ /^\d+$/
                row[key]
              elsif row[key].present?
                connection.quote(row[key])
              end
              values << "#{key} = #{value}" if value.present?
            end

            updates << "UPDATE #{klass.table_name} SET #{values.join(', ')} WHERE #{klass.primary_key} = #{row['customizable_id']}" if values.present?
          end
        end
      end
    end

    if dryrun?
      File.open('update.sql', 'w') do |file|
        file << updates.join(";\n")
      end
    else
      updates.each do |update|
        connection.execute update
      end
    end
  end
end
