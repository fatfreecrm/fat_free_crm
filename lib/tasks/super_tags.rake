namespace :super_tags do

  desc "Migrate super_tags plugin to core custom_fields"
  task :migrate => :environment do
    def dryrun?
      true
      #~ ENV['DRYRUN'] == 'true'
    end

    connection = ActiveRecord::Base.connection

    columns = %w(tag_id field_name field_type field_label table_name select_options max_size required disabled form_field_type field_info)

    field_data = connection.select_all "SELECT #{columns.join(', ')} FROM customfields"

    group_ids = {}

    tag_ids = field_data.map {|row| row['tag_id']}.uniq
    tag_ids.each do |tag_id|
      tag = ActsAsTaggableOn::Tag.find(tag_id)
      group_params = {:tag_id => tag.id, :name => tag.name}
      if dryrun?
        puts group_params
      else
        group = CustomFieldGroup.create group_params
        group_ids[tag_id] = group.id
      end
    end

    field_data.each do |row|
      if (table_name = row['table_name']).present?
        field_params = {
          :klass_name => table_name.singularize.camelize,
          :name       => row['field_name'],
          :label      => row['field_label'],
          :position   => row['position'],
          :collection => row['select_options'],
          :on         => row['form_field_type'],
          :hint       => row['field_info'],
          :required   => row['required'],
          :disabled   => row['disabled'],
          :maxlength  => row['max_size'],
          :field_group_id => group_ids[row['tag_id']]
        }
        if dryrun?
          puts field_params
        else
          field = CustomField.create field_params
        end
      end
    end

    tag_ids.each do |tag_id|
      data = connection.select_all "SELECT * FROM tag#{tag_id}s"
      keys = data.first.keys.reject {|k| %w(id customizable_type).include?(k)}

      klass_names = data.map {|row| row['customizable_type']}.uniq
      klass_names.each do |klass_name|
        klass = klass_name.constantize
        values = data.map do |row|
          keys.map {|k| row[k] =~ /^\d$/ ? row[k] : "'#{row[k]}'"}.join(', ')
        end
        keys.shift # We don't need customizable_id anymore

        insert = %Q{
          INSERT INTO #{klass.table_name} (#{([klass.primary_key] + keys).join(', ')})
            VALUES (#{values.join('), (')})
            ON DUPLICATE KEY UPDATE #{keys.map {|k| "#{k} = VALUES(#{k})"}.join(', ')}
        }
        if dryrun?
          puts insert
        else
          connection.execute insert
        end
      end
    end
  end
end
